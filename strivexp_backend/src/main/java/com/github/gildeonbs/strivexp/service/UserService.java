package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.UserDtos.*;
//import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceConflictException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.UsernameAlreadyExistsException;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserSettings;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.repository.UserSettingsRepository;
import lombok.RequiredArgsConstructor;
//import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final UserSettingsRepository userSettingsRepository;

    /**
     * Fetches the full user profile including settings.
     */
    @Transactional(readOnly = true)
    public UserProfileResponse getMyProfile(String email) {
        User user = userRepository.findByEmail(email)
                // Use Custom Exception here for 404
                .orElseThrow(() -> new ResourceNotFoundException("User not found with email: " + email));

        UserSettings settings = userSettingsRepository.findById(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Settings not found for user"));

        return mapToProfileResponse(user, settings);
    }

    /**
     * Updates core user profile information.
     */
    @Transactional
    public UserProfileResponse updateProfile(String email, UpdateProfileRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        boolean profileUpdated = false;

        if (request.displayName() != null &&
                !request.displayName().equals(user.getDisplayName())) {
            user.setDisplayName(request.displayName());
            profileUpdated = true;
        }

        if (request.avatar() != null &&
                !request.avatar().equals(user.getAvatar())) {
            user.setAvatar(request.avatar());
            profileUpdated = true;
        }

        if (request.username() != null &&
                !request.username().equals(user.getUsername())) {
            if (userRepository.existsByUsername(request.username())) {
                /*
                throw new ResourceConflictException("Username already exists");
                throw new DataIntegrityViolationException("Username already exists");
                */
                throw new UsernameAlreadyExistsException("Username already exists");
            }
            user.setUsername(request.username());
            profileUpdated = true;
        }

        if (profileUpdated) {
            userRepository.save(user);
        }

        //User savedUser = userRepository.save(user);
        UserSettings settings = userSettingsRepository.findById(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Settings not found for user"));

        //return mapToProfileResponse(savedUser, settings);
        return mapToProfileResponse(user, settings);
    }

    /**
     * Updates user preferences/settings.
     */
    @Transactional
    public UserProfileResponse updateSettings(String email, UpdateSettingsRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        UserSettings settings = userSettingsRepository.findById(user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Settings not found"));

        if (request.dailyNotificationTime() != null) settings.setDailyNotificationTime(request.dailyNotificationTime());
        if (request.locale() != null) settings.setLocale(request.locale());
        if (request.receiveMarketing() != null) settings.setReceiveMarketing(request.receiveMarketing());
        if (request.dailyChallengeLimit() != null) settings.setDailyChallengeLimit(request.dailyChallengeLimit());
        if (request.vibrationEnabled() != null) settings.setVibrationEnabled(request.vibrationEnabled());
        if (request.motivationalMessagesEnabled() != null) settings.setMotivationalMessagesEnabled(request.motivationalMessagesEnabled());
        if (request.soundEffectsEnabled() != null) settings.setSoundEffectsEnabled(request.soundEffectsEnabled());

        UserSettings savedSettings = userSettingsRepository.save(settings);

        return mapToProfileResponse(user, savedSettings);
    }

    private UserProfileResponse mapToProfileResponse(User user, UserSettings settings) {
        UserSettingsDto settingsDto = new UserSettingsDto(
                settings.getDailyNotificationTime(),
                settings.getLocale(),
                settings.getReceiveMarketing(),
                settings.getDailyChallengeLimit(),
                settings.getVibrationEnabled(),
                settings.getMotivationalMessagesEnabled(),
                settings.getSoundEffectsEnabled()
        );

        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getDisplayName(),
                user.getUsername(),
                user.getAvatar(),
                user.getBirthdayDate(),
                user.getLocale(),
                settingsDto
        );
    }
}
