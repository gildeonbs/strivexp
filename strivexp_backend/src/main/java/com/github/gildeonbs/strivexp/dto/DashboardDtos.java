package com.github.gildeonbs.strivexp.dto;

import com.github.gildeonbs.strivexp.dto.UserChallengeDto;
import com.github.gildeonbs.strivexp.dto.GamificationDtos.UserProgressDto;
import java.time.LocalDate;
import java.util.List;

public class DashboardDtos {

    public record HomeDashboardResponse(
            String displayName,
            String avatar,
            String motivationQuote, // Random or daily quote
            LocalDate date,
            UserProgressDto progress, // Reusing existing DTO (XP + Streak)
            List<UserChallengeDto> dailyChallenges
    ) {}
}