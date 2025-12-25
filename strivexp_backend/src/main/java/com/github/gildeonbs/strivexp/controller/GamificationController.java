package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.GamificationDtos.UserProgressDto;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.service.XpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/gamification")
@RequiredArgsConstructor
public class GamificationController {

    private final XpService xpService;
    private final UserRepository userRepository;

    @GetMapping("/progress")
    public ResponseEntity<UserProgressDto> getMyProgress(Authentication authentication) {
        User user = userRepository.findByEmail(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return ResponseEntity.ok(xpService.getUserProgress(user.getId()));
    }
}
