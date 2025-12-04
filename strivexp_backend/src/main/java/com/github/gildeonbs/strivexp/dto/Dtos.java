package com.github.gildeonbs.strivexp.dto;

import com.github.gildeonbs.strivexp.model.enums.ChallengeStatus;
import java.time.LocalDate;
import java.util.UUID;

// Using Java 21 Records for concise DTOs

public class Dtos {

    public record ChallengeResponseDto(
        UUID id,
        String title,
        String description,
        Integer xpReward,
        String categoryName,
        Short difficulty
    ) {}

    public record UserChallengeDto(
        UUID id,
        ChallengeResponseDto challenge,
        LocalDate assignedDate,
        ChallengeStatus status,
        Integer xpAwarded
    ) {}

    public record CompleteChallengeRequest(
        String note
    ) {}
}
