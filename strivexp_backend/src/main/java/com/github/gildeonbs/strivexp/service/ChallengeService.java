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
import java.util.Optional;
import java.util.Random;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChallengeService {

    private final ChallengeRepository challengeRepository;
    private final UserChallengeRepository userChallengeRepository;
    private final UserRepository userRepository;

    // Inject UserCategoryRepository for filtering
    private final UserCategoryRepository userCategoryRepository;

    private final XpService xpService;
    private final StreakService streakService;

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

        // --- NEW LOGIC START ---
        // 1. Get user's preferred categories
        List<UUID> preferredCategoryIds = userCategoryRepository.findCategoryIdsByUserId(userId);

        List<Challenge> dailyChallenges;
        if (preferredCategoryIds.isEmpty()) {
            // Fallback: If no preference selected, show ALL active daily challenges
            dailyChallenges = challengeRepository.findByRecurrenceAndIsActiveTrue(ChallengeRecurrence.DAILY);
        } else {
            // Filter: Only show challenges from selected categories
            dailyChallenges = challengeRepository.findByRecurrenceAndIsActiveTrueAndCategoryIdIn(
                    ChallengeRecurrence.DAILY, preferredCategoryIds
            );
        }
        // --- NEW LOGIC END ---

        // Limit to 1 challenges (or user setting limit)
        // Shuffling to ensure randomness
        // Collections.shuffle(dailyChallenges);
        // List<Challenge> selected = dailyChallenges.stream().limit(1).toList();
        List<UserChallenge> newAssignments = dailyChallenges.stream()
                .limit(1)
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
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found with id: " + userChallengeId));

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

    // Skip & Replace Logic ---

    @Transactional
    public UserChallengeDto skipChallenge(UUID userChallengeId) {
        UserChallenge assignment = userChallengeRepository.findById(userChallengeId)
                .orElseThrow(() -> new ResourceNotFoundException("Assignment not found with id: " + userChallengeId));

        if (assignment.getStatus() != ChallengeStatus.ASSIGNED) {
            throw new BadRequestException("Only assigned challenges can be skipped.");
        }

        // 1. Mark as Skipped
        assignment.setStatus(ChallengeStatus.SKIPPED);
        userChallengeRepository.save(assignment);

        // 2. Try to find a replacement
        Optional<Challenge> replacement = findReplacementChallenge(assignment.getUser());

        if (replacement.isPresent()) {
            UserChallenge newAssignment = UserChallenge.builder()
                    .user(assignment.getUser())
                    .challenge(replacement.get())
                    .assignedDate(LocalDate.now())
                    .status(ChallengeStatus.ASSIGNED)
                    .xpAwarded(0)
                    .note("Replacement for skipped challenge")
                    .build();

            UserChallenge savedReplacement = userChallengeRepository.save(newAssignment);

            // Return the NEW challenge so the UI can swap it in immediately
            return mapToDto(savedReplacement);
        }

        // If no replacement found (e.g. they did ALL available challenges), return the skipped one
        // The UI handles this by showing "Skipped" and no new item.
        return mapToDto(assignment);
    }

    private Optional<Challenge> findReplacementChallenge(User user) {
        LocalDate today = LocalDate.now();
        UUID userId = user.getId();

        // A. Get IDs of challenges already assigned/completed/skipped TODAY
        List<UUID> assignedChallengeIds = userChallengeRepository.findByUserIdAndAssignedDate(userId, today)
                .stream()
                .map(uc -> uc.getChallenge().getId())
                .collect(Collectors.toList());

        // B. Get User Preferences
        List<UUID> preferredCategoryIds = userCategoryRepository.findCategoryIdsByUserId(userId);

        // C. Fetch Candidates
        List<Challenge> candidates;
        if (preferredCategoryIds.isEmpty()) {
            candidates = challengeRepository.findByRecurrenceAndIsActiveTrue(ChallengeRecurrence.DAILY);
        } else {
            candidates = challengeRepository.findByRecurrenceAndIsActiveTrueAndCategoryIdIn(
                    ChallengeRecurrence.DAILY, preferredCategoryIds
            );
        }

        // D. Filter out ones already assigned
        List<Challenge> available = candidates.stream()
                .filter(c -> !assignedChallengeIds.contains(c.getId()))
                .collect(Collectors.toList());

        if (available.isEmpty()) {
            return Optional.empty();
        }

        // E. Pick a random one
        return Optional.of(available.get(new Random().nextInt(available.size())));
    }

    private UserChallengeDto mapToDto(UserChallenge uc) {
        Challenge c = uc.getChallenge();
        ChallengeResponseDto cDto = new ChallengeResponseDto(
                c.getId(), c.getTitle(), c.getDescription(), c.getXpReward(),
                c.getCategory().getName(), c.getCategory().getIcon(), c.getDifficulty()
        );
        return new UserChallengeDto(uc.getId(), cDto, uc.getAssignedDate(), uc.getStatus(), uc.getXpAwarded());
    }
}