package com.github.gildeonbs.strivexp.dto;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

public class UserDtos {

    public record UserProfileResponse(
        UUID id,
        String email,
        String displayName,
        String username,
        String avatar,
        LocalDate birthday,
        String locale,
        UserSettingsDto settings
    ) {}

    public record UserSettingsDto(
        LocalTime dailyNotificationTime,
        String locale,
        Boolean receiveMarketing,
        Short dailyChallengeLimit,
        Boolean vibrationEnabled,
        Boolean motivationalMessagesEnabled,
        Boolean soundEffectsEnabled
    ) {}

    public record UpdateProfileRequest(
        String displayName,
        String avatar, // URL or Base64 string depending on my storage strategy
        String username
    ) {}

    public record UpdateSettingsRequest(
        LocalTime dailyNotificationTime,
        String locale,
        Boolean receiveMarketing,
        Short dailyChallengeLimit,
        Boolean vibrationEnabled,
        Boolean motivationalMessagesEnabled,
        Boolean soundEffectsEnabled
    ) {}
}
