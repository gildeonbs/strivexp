package com.github.gildeonbs.strivexp.dto;

import java.time.LocalDate;

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
}
