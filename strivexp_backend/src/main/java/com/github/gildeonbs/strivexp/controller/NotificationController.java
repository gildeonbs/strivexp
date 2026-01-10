package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.NotificationDtos.RegisterPushTokenRequest;
import com.github.gildeonbs.strivexp.service.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @PostMapping("/token")
    public ResponseEntity<Void> registerToken(
            Authentication authentication,
            @RequestBody RegisterPushTokenRequest request) {

        notificationService.registerToken(authentication.getName(), request);
        return ResponseEntity.ok().build();
    }
}