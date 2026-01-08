package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.BadgeDtos.UserBadgeDto;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.Badge;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserBadge;
import com.github.gildeonbs.strivexp.repository.BadgeRepository;
import com.github.gildeonbs.strivexp.repository.UserBadgeRepository;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class BadgeService {

    private final BadgeRepository badgeRepository;
    private final UserBadgeRepository userBadgeRepository;
    private final UserRepository userRepository;

    /**
     * Fetch all badges earned by the user.
     */
    @Transactional(readOnly = true)
    public List<UserBadgeDto> getUserBadges(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        return userBadgeRepository.findByUserId(user.getId())
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    /**
     * Checks if a user qualifies for a streak badge.
     * Called by StreakService.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void checkStreakBadges(User user, int currentStreak) {
        if (currentStreak >= 3) {
            awardBadgeIfNotExists(user, "STREAK_3");
        }
        if (currentStreak >= 7) {
            awardBadgeIfNotExists(user, "STREAK_7");
        }
        if (currentStreak >= 30) {
            awardBadgeIfNotExists(user, "STREAK_30");
        }
    }

    /**
     * Checks if a user qualifies for a level badge.
     * Called by XpService.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void checkLevelBadges(User user, int newLevel) {
        if (newLevel >= 5) {
            awardBadgeIfNotExists(user, "LEVEL_5");
        }
        if (newLevel >= 10) {
            awardBadgeIfNotExists(user, "LEVEL_10");
        }
    }

    private void awardBadgeIfNotExists(User user, String badgeCode) {
        if (userBadgeRepository.existsByUserIdAndBadgeCode(user.getId(), badgeCode)) {
            return; // Already has it
        }

        Optional<Badge> badgeOpt = badgeRepository.findByCode(badgeCode);
        if (badgeOpt.isPresent()) {
            Badge badge = badgeOpt.get();
            UserBadge userBadge = UserBadge.builder()
                    .user(user)
                    .badge(badge)
                    .build();
            userBadgeRepository.save(userBadge);
            log.info("BADGE AWARDED: {} to User {}", badgeCode, user.getEmail());

            // TODO: In future, push notification or add to a "Recent Events" queue for UI popup
        }
    }

    private UserBadgeDto mapToDto(UserBadge ub) {
        return new UserBadgeDto(
                ub.getBadge().getCode(),
                ub.getBadge().getName(),
                ub.getBadge().getDescription(),
                ub.getBadge().getIconUrl(),
                ub.getAwardedAt()
        );
    }
}