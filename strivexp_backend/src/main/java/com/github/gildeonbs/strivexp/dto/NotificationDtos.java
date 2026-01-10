package com.github.gildeonbs.strivexp.dto;

import com.github.gildeonbs.strivexp.model.enums.PlatformType;

public class NotificationDtos {

    public record RegisterPushTokenRequest(
            String token,
            PlatformType platform
    ) {}

    public record NotificationHistoryResponse(
            String title,
            String body,
            String status,
            String sentAt
    ) {}
}