package com.github.gildeonbs.strivexp.dto;

import com.github.gildeonbs.strivexp.model.enums.ChallengeStatus;

import java.time.LocalDate;
import java.time.Instant;
import java.util.UUID;

public record UserChallengeDto(
        UUID id,
        ChallengeResponseDto challenge,
        LocalDate assignedDate,
        ChallengeStatus status,
        Integer xpAwarded,
        Instant updatedAt
) {}
