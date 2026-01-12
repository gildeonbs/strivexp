package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.exception.CustomExceptions.BadRequestException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceConflictException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.PasswordResetToken;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.repository.PasswordResetTokenRepository;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class PasswordResetService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder; // Reuse the BCrypt encoder

    @Value("${app.frontend.url}")
    private String frontendUrl;

    // Security Constants
    private static final int EXPIRATION_MINUTES = 15;
    private static final int RATE_LIMIT_requests = 3;
    private static final int RATE_LIMIT_MINUTES = 60;

    @Transactional
    public void requestPasswordReset(String email) {
        // 1. Silent failure to prevent Email Enumeration
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            log.info("Password reset requested for non-existent email: {}", email);
            return;
        }

        // 2. Rate Limiting
        Instant oneHourAgo = Instant.now().minus(RATE_LIMIT_MINUTES, ChronoUnit.MINUTES);
        long recentRequests = tokenRepository.countByUserAndCreatedAtAfter(user, oneHourAgo);
        if (recentRequests >= RATE_LIMIT_requests) {
            log.warn("Rate limit exceeded for user {}", user.getId());
            return;
        }

        // 3. Generate Token
        // 'tokenId' is public (for DB lookup)
        // 'tokenSecret' is private (sent to user, hashed in DB)
        String tokenSecret = generateSecureToken();
        String tokenHash = passwordEncoder.encode(tokenSecret);

        PasswordResetToken resetToken = PasswordResetToken.builder()
                .user(user)
                .tokenHash(tokenHash)
                .expiryDate(Instant.now().plus(EXPIRATION_MINUTES, ChronoUnit.MINUTES))
                .used(false)
                .build();

        resetToken = tokenRepository.save(resetToken);

        // 4. Construct Link
        // Format: https://frontend.com/reset-password?id={public_uuid}&token={secret_string}
        String link = String.format("%s/reset-password?id=%s&token=%s",
                frontendUrl, resetToken.getId(), tokenSecret);

        // 5. Send Email
        emailService.sendPasswordResetEmail(user.getEmail(), link);
    }

    @Transactional
    public void confirmPasswordReset(UUID tokenId, String tokenSecret, String newPassword) {
        // 1. Lookup by Public ID
        PasswordResetToken resetToken = tokenRepository.findById(tokenId)
                .orElseThrow(() -> new BadRequestException("Invalid or expired password reset token"));

        // 2. Checks
        if (resetToken.isUsed()) {
            throw new BadRequestException("Token already used");
        }
        if (resetToken.isExpired()) {
            throw new BadRequestException("Token expired");
        }

        // 3. Verify Secret against Hash
        if (!passwordEncoder.matches(tokenSecret, resetToken.getTokenHash())) {
            throw new BadRequestException("Invalid token");
        }

        // 4. Update Password
        User user = resetToken.getUser();
        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        // 5. Invalidate Token
        resetToken.setUsed(true);
        tokenRepository.save(resetToken);

        log.info("Password reset successfully for user {}", user.getId());
    }

    private String generateSecureToken() {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
}