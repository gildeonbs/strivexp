package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.UserDtos.*;
import com.github.gildeonbs.strivexp.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    // GET /api/users/me
    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> getMyProfile(Authentication authentication) {
        return ResponseEntity.ok(userService.getMyProfile(authentication.getName()));
    }

    // PATCH /api/users/me
    @PatchMapping("/me")
    public ResponseEntity<UserProfileResponse> updateProfile(
            Authentication authentication, 
            @RequestBody UpdateProfileRequest request) {
        return ResponseEntity.ok(userService.updateProfile(authentication.getName(), request));
    }

    // PATCH /api/users/me/settings
    @PatchMapping("/me/settings")
    public ResponseEntity<UserProfileResponse> updateSettings(
            Authentication authentication, 
            @RequestBody UpdateSettingsRequest request) {
        return ResponseEntity.ok(userService.updateSettings(authentication.getName(), request));
    }
}

