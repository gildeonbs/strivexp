package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.config.security.JwtService;
import com.github.gildeonbs.strivexp.dto.AuthPayloads.*;
import com.github.gildeonbs.strivexp.model.RefreshToken;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserSettings;
import com.github.gildeonbs.strivexp.repository.RefreshTokenRepository;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository; // To init settings
    private final RefreshTokenRepository refreshTokenRepository; // To handle sessions
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    // Refresh Token Duration: 7 Days
    private static final long REFRESH_DURATION_MS = 604800000L; 

    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        var user = User.builder()
                .displayName(request.firstName() + " " + request.lastName())
                .lastName(request.lastName())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .birthdayDate(request.birthday())
                .isActive(true)
                .locale("en_US")
                .timezone("UTC")
                .build();
        
        User savedUser = userRepository.save(user);

        // ADJUST: Initialize User Settings immediately
        UserSettings settings = UserSettings.builder()
                .user(savedUser)
                .locale("en_US")
                // Defaults are handled by @Builder.Default in entity
                .build();
        userSettingsRepository.save(settings);

        UserDetails userDetails = userDetailsService.loadUserByUsername(savedUser.getEmail());
        
        String accessToken = generateAccessToken(savedUser, userDetails);
        String refreshToken = createRefreshToken(savedUser);

        return new AuthenticationResponse(accessToken, refreshToken);
    }

    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.email(),
                        request.password()
                )
        );
        
        var user = userRepository.findByEmail(request.email())
                .orElseThrow();
                
        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        
        String accessToken = generateAccessToken(user, userDetails);
        String refreshToken = createRefreshToken(user); // Rotates token on login

        return new AuthenticationResponse(accessToken, refreshToken);
    }

    @Transactional
    public AuthenticationResponse refreshToken(RefreshTokenRequest request) {
        return refreshTokenRepository.findByToken(request.refreshToken())
                .map(token -> {
                    // 1. Verify Expiration
                    if (token.getExpiryDate().isBefore(Instant.now())) {
                        refreshTokenRepository.delete(token); // Clean up
                        throw new RuntimeException("Refresh token expired. Please login again.");
                    }
                    // 2. Verify Revocation
                    if (token.isRevoked()) {
                        throw new RuntimeException("Refresh token revoked.");
                    }
                    return token;
                })
                .map(token -> {
                    // 3. Generate New Access Token
                    User user = token.getUser();
                    UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
                    String accessToken = generateAccessToken(user, userDetails);
                    
                    // Optional: Rotate Refresh Token (Safety) or keep same. 
                    // Keeping same for simplicity, but updating logic could go here.
                    
                    return new AuthenticationResponse(accessToken, request.refreshToken());
                })
                .orElseThrow(() -> new RuntimeException("Refresh token not found"));
    }

    private String createRefreshToken(User user) {
        // Revoke old tokens? (Optional: for strict single-session)
        // refreshTokenRepository.deleteAll(refreshTokenRepository.findAllByUser(user));

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiryDate(Instant.now().plusMillis(REFRESH_DURATION_MS))
                .revoked(false)
                .build();
        
        return refreshTokenRepository.save(refreshToken).getToken();
    }

    private String generateAccessToken(User user, UserDetails userDetails) {
        Map<String, Object> extraClaims = new HashMap<>();
        extraClaims.put("userId", user.getId());
        return jwtService.generateToken(extraClaims, userDetails);
    }
}
