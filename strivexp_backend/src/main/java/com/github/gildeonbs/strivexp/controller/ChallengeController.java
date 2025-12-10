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
        // In a real app with Security, extract UUID from 'authentication' principal
        // For now, we mock it or pass it via header for testing if auth isn't fully ready
        // UUID userId = UUID.fromString(authentication.getName()); 
        
        // MOCK ID for demonstration (Replace with actual Auth extraction)
        //UUID userId = UUID.fromString("00000000-0000-0000-0000-000000000001"); 
        UUID userId = UUID.fromString("374a2827-aecd-497a-aefe-3cdfcf448944"); 

        return ResponseEntity.ok(challengeService.getOrAssignDailyChallenges(userId));
    }

    // Endpoint: POST /api/challenges/{id}/complete
    @PostMapping("/{id}/complete")
    public ResponseEntity<UserChallengeDto> completeChallenge(
            @PathVariable UUID id,
            @RequestBody CompleteChallengeRequest request) {
        
        return ResponseEntity.ok(challengeService.completeChallenge(id, request));
    }
}
