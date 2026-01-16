package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.*;
import com.github.gildeonbs.strivexp.service.ChallengeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/challenges")
@RequiredArgsConstructor
public class ChallengeController {

    private final ChallengeService challengeService;

    // Endpoint: GET /api/challenges/daily
    @GetMapping("/daily")
    public ResponseEntity<List<UserChallengeDto>> getDailyChallenges(Authentication authentication) {
        // Now extracting the real email from the SecurityContext
        String userEmail = authentication.getName(); 
        
        return ResponseEntity.ok(challengeService.getOrAssignDailyChallenges(userEmail));
    }

    // Endpoint: POST /api/challenges/{id}/complete
    @PostMapping("/{id}/complete")
    public ResponseEntity<UserChallengeDto> completeChallenge(
            @PathVariable UUID id,
            @RequestBody CompleteChallengeRequest request) {
        
        return ResponseEntity.ok(challengeService.completeChallenge(id, request));
    }

    @PostMapping("/{id}/skip")
    public ResponseEntity<UserChallengeDto> skipChallenge(@PathVariable UUID id) {
        return ResponseEntity.ok(challengeService.skipChallenge(id));
    }
}
