package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.*;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.BadRequestException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
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
    
    private final XpService xpService;
    private final StreakService streakService; // Added StreakService

    @Transactional
    public List<UserChallengeDto> getOrAssignDailyChallenges(String userEmail) {
        LocalDate today = LocalDate.now();
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + userEmail));

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
                .orElseThrow(() -> new ResourceNotFoundException("UserChallenge not found with id: " + userChallengeId));

        if (assignment.getStatus() == ChallengeStatus.COMPLETED) {
            throw new BadRequestException("Challenge is already completed");
        }

        assignment.setStatus(ChallengeStatus.COMPLETED);
        assignment.setCompletedAt(Instant.now());
        assignment.setNote(request.note());
        
        int xpToAward = assignment.getChallenge().getXpReward();
        assignment.setXpAwarded(xpToAward);

        UserChallenge saved = userChallengeRepository.save(assignment);
        
        // 1. Award XP
        xpService.awardXp(
            assignment.getUser(), 
            xpToAward, 
            XpEventType.CHALLENGE_COMPLETION, 
            assignment.getId(), 
            "Completed challenge: " + assignment.getChallenge().getTitle()
        );

        // 2. Update Streak
        streakService.updateStreak(assignment.getUser().getId());

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
