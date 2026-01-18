package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.config.security.JwtService;
import com.github.gildeonbs.strivexp.dto.AuthPayloads.*;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.BadRequestException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.*;
import com.github.gildeonbs.strivexp.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final EmailVerificationTokenRepository emailVerificationRepository;
    private final PushTokenRepository pushTokenRepository; // Added for logout cleanup

    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;
    private final EmailService emailService;

    @Value("${app.frontend.url}")
    private String frontendUrl;

    // Refresh Token Duration: 7 Days
    //private static final long REFRESH_DURATION_MS = 604800000L;
    // Refresh Token Duration: 3 Days
    private static final long REFRESH_DURATION_MS = 259200000L;


    // --- 1. REGISTRATION ---
    @Transactional
    public AuthenticationResponse register(RegisterRequest request) {
        // DataIntegrityViolationException (duplicate email) is handled by GlobalExceptionHandler

        var user = User.builder()
                .displayName(request.firstName() + " " + request.lastName())
                .lastName(request.lastName())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .birthdayDate(request.birthday())
                .isActive(true)
                .emailVerified(false)
                .locale("en_US")
                .timezone("UTC")
                .build();

        User savedUser = userRepository.save(user);

        // Initialize Settings
        UserSettings settings = UserSettings.builder().user(savedUser).locale("en_US").build();
        userSettingsRepository.save(settings);

        // Send Verification Email
        createAndSendVerificationToken(savedUser);

        // Return Tokens immediately (Allow instant access)
        UserDetails userDetails = userDetailsService.loadUserByUsername(savedUser.getEmail());
        String accessToken = generateAccessToken(savedUser, userDetails);
        String refreshToken = createRefreshToken(savedUser);

        return new AuthenticationResponse(accessToken, refreshToken);
    }

    // --- 2. AUTHENTICATION ---
    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        // Check Credentials
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password())
        );

        var user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // BLOCK LOGIN if not verified
        if (!user.getEmailVerified()) {
            throw new BadRequestException("Please verify your email address before logging in.");
        }

        UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());

        String accessToken = generateAccessToken(user, userDetails);
        String refreshToken = createRefreshToken(user); // Rotates token on login

        return new AuthenticationResponse(accessToken, refreshToken);
    }

    // --- 3. REFRESH TOKEN ---
    @Transactional
    public AuthenticationResponse refreshToken(RefreshTokenRequest request) {
        return refreshTokenRepository.findByToken(request.refreshToken())
                .map(token -> {
                    // Check Expiry
                    if (token.getExpiryDate().isBefore(Instant.now())) {
                        refreshTokenRepository.delete(token);
                        throw new BadRequestException("Refresh token expired. Please login again.");
                    }
                    // Check Revocation
                    if (token.isRevoked()) {
                        throw new BadRequestException("Refresh token revoked.");
                    }
                    return token;
                })
                .map(token -> {
                    // Issue new Access Token
                    User user = token.getUser();
                    UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
                    String accessToken = generateAccessToken(user, userDetails);

                    // Return new Access Token + Existing Refresh Token
                    return new AuthenticationResponse(accessToken, request.refreshToken());
                })
                .orElseThrow(() -> new ResourceNotFoundException("Refresh token not found"));
    }

    // --- 4. EMAIL VERIFICATION ---
    @Transactional
    public void verifyEmail(UUID tokenId, String tokenSecret) {
        // Find Token by Public ID
        EmailVerificationToken verificationToken = emailVerificationRepository.findById(tokenId)
                .orElseThrow(() -> new BadRequestException("Invalid verification token"));

        // Check Expiry
        if (verificationToken.isExpired()) {
            throw new BadRequestException("Verification link expired. Please request a new one.");
        }

        // Verify Secret against Hash
        if (!passwordEncoder.matches(tokenSecret, verificationToken.getTokenHash())) {
            throw new BadRequestException("Invalid verification token");
        }

        // Update User
        User user = verificationToken.getUser();
        user.setEmailVerified(true);
        userRepository.save(user);

        // Delete Token (Single Use)
        emailVerificationRepository.delete(verificationToken);
    }

    //--- 5. LOGOUT METHOD ---
    @Transactional
    public void logout(LogoutRequest request) {
        // Revoke Refresh Token
        if (request.refreshToken() != null) {
            refreshTokenRepository.findByToken(request.refreshToken())
                    .ifPresent(token -> {
                        token.setRevoked(true);
                        refreshTokenRepository.save(token);
                    });
        }

        // Disable Push Token
        if (request.pushToken() != null) {
            pushTokenRepository.findByToken(request.pushToken())
                    .ifPresent(token -> {
                        token.setIsActive(false);
                        pushTokenRepository.save(token);
                    });
        }
    }

    // --- Helpers ---
    private void createAndSendVerificationToken(User user) {
        // Generate secure random string
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        String tokenSecret = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);

        String tokenHash = passwordEncoder.encode(tokenSecret);

        EmailVerificationToken token = EmailVerificationToken.builder()
                .user(user)
                .tokenHash(tokenHash)
                .expiryDate(Instant.now().plus(24, ChronoUnit.HOURS))
                .build();

        // Remove old token if exists to keep DB clean
        emailVerificationRepository.findByUser(user).ifPresent(emailVerificationRepository::delete);

        EmailVerificationToken savedToken = emailVerificationRepository.save(token);

        //String backendUrl = "http://localhost:8080";
        String link = String.format("%s/api/auth/verify-email?id=%s&token=%s",
                frontendUrl, savedToken.getId(), tokenSecret);

        emailService.sendVerificationEmail(user.getEmail(), link);
    }

    private String createRefreshToken(User user) {
        // Revoke old tokens? (for strict single-session)
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
