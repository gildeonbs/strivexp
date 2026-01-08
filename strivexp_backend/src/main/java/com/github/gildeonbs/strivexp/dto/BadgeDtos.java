package com.github.gildeonbs.strivexp.dto;

import java.time.Instant;

public class BadgeDtos {

    public record UserBadgeDto(
            String code,
            String name,
            String description,
            String iconUrl,
            Instant awardedAt
    ) {}
}
