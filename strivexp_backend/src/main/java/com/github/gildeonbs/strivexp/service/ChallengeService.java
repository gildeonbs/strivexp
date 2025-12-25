package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.*;
import com.github.gildeonbs.strivexp.model.*;
import com.github.gildeonbs.strivexp.model.enums.*;
import com.github.gildeonbs.strivexp.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChallengeService {

    private final ChallengeRepository challengeRepository;
    private final UserChallengeRepository userChallengeRepository;
    private final UserRepository userRepository;
    
    // Inject XP Service
    private final XpService xpService;

    @Transactional
    public List<UserChallengeDto> getOrAssignDailyChallenges(String userEmail) {
        LocalDate today = LocalDate.now();
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new RuntimeException("User not found"));

        UUID userId = user.getId();
        List<UserChallenge> existing = userChallengeRepository.findByUserIdAndAssignedDate(userId, today);
        
        if (!existing.isEmpty()) {
            return existing.stream().map(this::mapToDto).collect(Collectors.toList());
        }

        List<Challenge> dailyChallenges = challengeRepository.findByRecurrenceAndIsActiveTrue(ChallengeRecurrence.DAILY);

        List<UserChallenge> newAssignments = dailyChallenges.stream()
                .map(challenge -> UserChallenge.builder()
                        .user(user)
                        .challenge(challenge)
                        .assignedDate(today)
                        .status(ChallengeStatus.ASSIGNED)
                        .xpAwarded(0)
                        .build())
                .collect(Collectors.toList());

        List<UserChallenge> saved = userChallengeRepository.saveAll(newAssignments);
        log.info("Assigned {} challenges to user {}", saved.size(), userId);

        return saved.stream().map(this::mapToDto).collect(Collectors.toList());
    }

    @Transactional
    public UserChallengeDto completeChallenge(UUID userChallengeId, CompleteChallengeRequest request) {
        UserChallenge assignment = userChallengeRepository.findById(userChallengeId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        if (assignment.getStatus() == ChallengeStatus.COMPLETED) {
            throw new IllegalStateException("Challenge already completed");
        }

        assignment.setStatus(ChallengeStatus.COMPLETED);
        assignment.setCompletedAt(Instant.now());
        assignment.setNote(request.note());
        
        int xpToAward = assignment.getChallenge().getXpReward();
        assignment.setXpAwarded(xpToAward);

        UserChallenge saved = userChallengeRepository.save(assignment);
        
        // INTEGRATION: Fire XP Event
        xpService.awardXp(
            assignment.getUser(), 
            xpToAward, 
            XpEventType.CHALLENGE_COMPLETION, 
            assignment.getId(), 
            "Completed challenge: " + assignment.getChallenge().getTitle()
        );

        return mapToDto(saved);
    }

    private UserChallengeDto mapToDto(UserChallenge uc) {
        Challenge c = uc.getChallenge();
        ChallengeResponseDto cDto = new ChallengeResponseDto(
                c.getId(), c.getTitle(), c.getDescription(), c.getXpReward(), 
                c.getCategory().getName(), c.getDifficulty()
        );
        return new UserChallengeDto(uc.getId(), cDto, uc.getAssignedDate(), uc.getStatus(), uc.getXpAwarded());
    }
}
