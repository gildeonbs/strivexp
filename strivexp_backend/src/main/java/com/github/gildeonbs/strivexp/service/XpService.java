package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.GamificationDtos.*;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserStreak;
import com.github.gildeonbs.strivexp.model.XpEvent;
import com.github.gildeonbs.strivexp.model.enums.XpEventType;
import com.github.gildeonbs.strivexp.repository.XpEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class XpService {

    private final XpEventRepository xpEventRepository;
    private final StreakService streakService; // Injected to aggregate data

    // INTEGRATION: Badge Service
    private final BadgeService badgeService;

    // CONSTANTS for Leveling Logic
    private static final int BASE_XP_PER_LEVEL = 100;

    /**
     * Calculates full progress for a user (Level + XP + Streak).
     */
    public UserProgressDto getUserProgress(UUID userId) {
        long totalXp = xpEventRepository.getTotalXpByUserId(userId).orElse(0L);
        UserStreak streak = streakService.getStreak(userId); // Fetch streak info

        return calculateProgress(totalXp, streak);
    }

    /**
     * Awards XP and returns event details.
     */
    @Transactional
    public XpAwardedEvent awardXp(User user, Integer amount, XpEventType type, UUID referenceId, String note) {
        XpEvent event = XpEvent.builder()
                .user(user)
                .amount(amount)
                .type(type)
                .referenceId(referenceId)
                .note(note)
                .build();

        xpEventRepository.save(event);
        log.info("Awarded {} XP to user {}", amount, user.getId());

        // Check for Level Up
        long totalXpBefore = xpEventRepository.getTotalXpByUserId(user.getId()).orElse(0L) - amount;
        long totalXpAfter = totalXpBefore + amount;

        int oldLevel = calculateLevel(totalXpBefore);
        int newLevel = calculateLevel(totalXpAfter);

        // TRIGGER BADGE CHECK
        if (newLevel > oldLevel) {
            badgeService.checkLevelBadges(user, newLevel);
        }

        return new XpAwardedEvent(amount, type.name(), newLevel, newLevel > oldLevel);
    }

    private int calculateLevel(long totalXp) {
        return (int) (totalXp / BASE_XP_PER_LEVEL) + 1;
    }

    private UserProgressDto calculateProgress(long totalXp, UserStreak streak) {
        int currentLevel = calculateLevel(totalXp);

        long xpForNextLevelTotal = (long) currentLevel * BASE_XP_PER_LEVEL;
        long xpForCurrentLevelTotal = (long) (currentLevel - 1) * BASE_XP_PER_LEVEL;

        long xpInCurrentLevel = totalXp - xpForCurrentLevelTotal;
        long xpNeededForLevelUp = xpForNextLevelTotal - xpForCurrentLevelTotal;

        double percentage = (double) xpInCurrentLevel / xpNeededForLevelUp;

        // --- VISUAL FIX FOR STREAK ---
        // Ideally, if the last completed date is older than Yesterday, the streak is visually 0.
        // We calculate this "On Read" so we don't have to write to the DB every time.
        int displayStreak = streak.getCurrentStreak();
        LocalDate yesterday = LocalDate.now().minusDays(1);
        LocalDate today = LocalDate.now();

        if (streak.getLastCompletedDate() != null) {
            // If last completion was NOT today AND NOT yesterday, the streak is broken.
            boolean isBroken = streak.getLastCompletedDate().isBefore(yesterday);
            if (isBroken) {
                displayStreak = 0;
            }
        }

        return new UserProgressDto(
                currentLevel,
                totalXp,
                xpForNextLevelTotal,
                xpInCurrentLevel,
                percentage,
                displayStreak, // Send the calculated visual streak
                streak.getLongestStreak()
        );
    }
}
