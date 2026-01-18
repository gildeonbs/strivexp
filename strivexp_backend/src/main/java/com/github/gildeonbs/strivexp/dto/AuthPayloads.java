package com.github.gildeonbs.strivexp.dto;

import java.time.LocalDate;
import java.util.UUID;

public class AuthPayloads {

    public record RegisterRequest(
        String firstName,
        String lastName,
        String email,
        String password,
        LocalDate birthday
    ) {}

    public record AuthenticationRequest(
        String email,
        String password
    ) {}

    public record AuthenticationResponse(
        String accessToken,
        String refreshToken 
    ) {}

    public record RefreshTokenRequest(
        String refreshToken
    ) {}

    public record LogoutRequest(
            String refreshToken,
            String pushToken // If client sends this, it disables push for this device
    ) {}

    public record PasswordResetRequest(
            String email
    ) {}

    public record PasswordResetConfirm(
            String token, // The raw token string received in email
            UUID tokenId, // The public ID from the link to find the DB record
            String newPassword
    ) {}

    public record GenericResponse(
            String message
    ) {}
}
