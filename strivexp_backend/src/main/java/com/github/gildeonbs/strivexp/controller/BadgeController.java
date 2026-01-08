package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.BadgeDtos.UserBadgeDto;
import com.github.gildeonbs.strivexp.service.BadgeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/badges")
@RequiredArgsConstructor
public class BadgeController {

    private final BadgeService badgeService;

    @GetMapping("/me")
    public ResponseEntity<List<UserBadgeDto>> getMyBadges (Authentication authentication) {
        return ResponseEntity.ok(badgeService.getUserBadges(authentication.getName()));
    }
}
