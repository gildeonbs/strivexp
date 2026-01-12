package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.AuthPayloads.*;
import com.github.gildeonbs.strivexp.service.AuthService;
import com.github.gildeonbs.strivexp.service.PasswordResetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final PasswordResetService  passwordResetService;

    @PostMapping("/register")
    public ResponseEntity<AuthenticationResponse> register(
            @RequestBody RegisterRequest request
    ) {
        return ResponseEntity.ok(authService.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthenticationResponse> authenticate(
            @RequestBody AuthenticationRequest request
    ) {
        return ResponseEntity.ok(authService.authenticate(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthenticationResponse> refreshToken(
            @RequestBody RefreshTokenRequest request
    ) {
        return ResponseEntity.ok(authService.refreshToken(request));
    }

    // --- Password Reset Endpoints ---

    @PostMapping("/password-reset/request")
    public ResponseEntity<GenericResponse> requestPasswordReset(@RequestBody PasswordResetRequest request) {
        passwordResetService.requestPasswordReset(request.email());
        // Always return 200 OK with same message to prevent email enumeration
        return ResponseEntity.ok(new GenericResponse("If the email exists, a reset link was sent."));
    }

    @PostMapping("/password-reset/confirm")
    public ResponseEntity<GenericResponse> confirmPasswordReset(@RequestBody PasswordResetConfirm request) {
        passwordResetService.confirmPasswordReset(request.tokenId(), request.token(), request.newPassword());
        return ResponseEntity.ok(new GenericResponse("Password successfully updated. Please login."));
    }
}
