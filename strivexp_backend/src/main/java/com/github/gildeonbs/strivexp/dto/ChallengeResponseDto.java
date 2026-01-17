package com.github.gildeonbs.strivexp.dto;

import java.util.UUID;

public record ChallengeResponseDto(
        UUID id,
        String title,
        String description,
        Integer xpReward,
        String categoryName,
        String icon,
        Short difficulty
) {}
