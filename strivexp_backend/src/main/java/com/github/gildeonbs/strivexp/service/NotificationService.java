package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.NotificationDtos.RegisterPushTokenRequest;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.PushToken;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.repository.PushTokenRepository;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationService {

    private final PushTokenRepository pushTokenRepository;
    private final UserRepository userRepository;

    @Transactional
    public void registerToken(String userEmail, RegisterPushTokenRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        PushToken pushToken = pushTokenRepository.findByToken(request.token())
                .orElse(PushToken.builder()
                        .token(request.token())
                        .build());

        // Update ownership and metadata
        pushToken.setUser(user);
        pushToken.setPlatform(request.platform());
        pushToken.setLastSeenAt(Instant.now());
        pushToken.setIsActive(true);

        pushTokenRepository.save(pushToken);
        log.info("Registered push token for user {} on {}", user.getId(), request.platform());
    }

    // TODO: In the future, add 'sendNotification(User user, String title, String body)' method
    // which integrates with Firebase Admin SDK to actually send the message.
}