package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.DashboardDtos.HomeDashboardResponse;
import com.github.gildeonbs.strivexp.dto.UserChallengeDto;
import com.github.gildeonbs.strivexp.dto.GamificationDtos.UserProgressDto;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserSettings;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;

    // Inject existing services to reuse logic
    private final ChallengeService challengeService;
    private final XpService xpService;

    @Transactional
    public HomeDashboardResponse getHomeDashboard(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + userEmail));

        // 1. Get Progress (XP + Level + Streak)
        UserProgressDto progress = xpService.getUserProgress(user.getId());

        // 2. Get (or Assign) Daily Challenges
        List<UserChallengeDto> challenges = challengeService.getOrAssignDailyChallenges(userEmail);

        // 3. Get Motivation (Dynamic based on settings)
        String quote = "Keep pushing forward!";
        UserSettings settings = userSettingsRepository.findById(user.getId()).orElse(null);
        if (settings != null && !settings.getMotivationalMessagesEnabled()) {
            quote = null; // UI handles null by hiding the quote box
        } else {
            // TODO: In future, fetch from a generic 'Quotes' table or service
            quote = "Consistency is the key to success.";
        }

        return new HomeDashboardResponse(
                user.getDisplayName(),
                user.getAvatar(),
                quote,
                LocalDate.now(),
                progress,
                challenges
        );
    }
}