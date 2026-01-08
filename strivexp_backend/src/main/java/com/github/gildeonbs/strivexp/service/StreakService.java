package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserStreak;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.repository.UserStreakRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class StreakService {

    private final UserStreakRepository userStreakRepository;
    private final UserRepository userRepository;

    // INTEGRATION: Badge Service
    private final BadgeService badgeService;

    /**
     * Updates the user's streak based on activity today.
     * Uses REQUIRES_NEW to ensure streak updates happen even if the parent transaction has issues,
     * though typically standard transactional propagation is fine here.
     */
    @Transactional(propagation = Propagation.REQUIRED)
    public void updateStreak(UUID userId) {
        LocalDate today = LocalDate.now();

        UserStreak streak = userStreakRepository.findById(userId)
                .orElseGet(() -> initializeStreak(userId));

        // 1. If already updated today, ignore
        if (today.equals(streak.getLastCompletedDate())) {
            return;
        }

        // 2. Check if streak continues (Last date was yesterday)
        if (streak.getLastCompletedDate() != null && streak.getLastCompletedDate().equals(today.minusDays(1))) {
            streak.setCurrentStreak(streak.getCurrentStreak() + 1);
        } else {
            // 3. Broken streak (or first time) -> Reset to 1
            streak.setCurrentStreak(1);
        }

        // 4. Update max streak
        if (streak.getCurrentStreak() > streak.getLongestStreak()) {
            streak.setLongestStreak(streak.getCurrentStreak());
        }

        // 5. Save state
        streak.setLastCompletedDate(today);
        userStreakRepository.save(streak);
        log.info("Updated streak for user {}: Current={}, Longest={}", userId, streak.getCurrentStreak(), streak.getLongestStreak());

        // TRIGGER BADGE CHECK
        badgeService.checkStreakBadges(streak.getUser(), streak.getCurrentStreak());
    }

    public UserStreak getStreak(UUID userId) {
        return userStreakRepository.findById(userId)
                .orElseGet(() -> initializeStreak(userId));
    }

    private UserStreak initializeStreak(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new  ResourceNotFoundException("User not found with id: " + userId));
        return UserStreak.builder()
                .user(user)
                .currentStreak(0)
                .longestStreak(0)
                .build();
    }
}
