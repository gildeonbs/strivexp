package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.UserDtos.UpdateProfileRequest;
import com.github.gildeonbs.strivexp.dto.UserDtos.UpdateSettingsRequest;
import com.github.gildeonbs.strivexp.dto.UserDtos.UserProfileResponse;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserSettings;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import com.github.gildeonbs.strivexp.repository.UserSettingsRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private UserSettingsRepository userSettingsRepository;

    @InjectMocks
    private UserService userService;

    private User mockUser;
    private UserSettings mockSettings;
    private final String TEST_EMAIL = "test@example.com";
    private final UUID USER_ID = UUID.randomUUID();

    @BeforeEach
    void setUp() {
        mockUser = User.builder()
                .id(USER_ID)
                .email(TEST_EMAIL)
                .displayName("Test User")
                .username("testuser")
                .birthdayDate(LocalDate.of(1990, 1, 1))
                .build();

        mockSettings = UserSettings.builder()
                .userId(USER_ID)
                .user(mockUser)
                .locale("en_US")
                .dailyChallengeLimit((short) 3)
                .build();
    }

    @Test
    @DisplayName("Should return user profile when user exists")
    void getMyProfile_Success() {
        // Arrange
        when(userRepository.findByEmail(TEST_EMAIL)).thenReturn(Optional.of(mockUser));
        when(userSettingsRepository.findById(USER_ID)).thenReturn(Optional.of(mockSettings));

        // Act
        UserProfileResponse response = userService.getMyProfile(TEST_EMAIL);

        // Assert
        assertNotNull(response);
        assertEquals(USER_ID, response.id());
        assertEquals("Test User", response.displayName());
        assertEquals("en_US", response.settings().locale());

        verify(userRepository).findByEmail(TEST_EMAIL);
        verify(userSettingsRepository).findById(USER_ID);
    }

    @Test
    @DisplayName("Should throw ResourceNotFoundException when user does not exist")
    void getMyProfile_UserNotFound() {
        // Arrange
        when(userRepository.findByEmail(TEST_EMAIL)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(ResourceNotFoundException.class, () -> {
            userService.getMyProfile(TEST_EMAIL);
        });

        verify(userSettingsRepository, never()).findById(any());
    }

    @Test
    @DisplayName("Should update profile fields correctly")
    void updateProfile_Success() {
        // Arrange
        UpdateProfileRequest request = new UpdateProfileRequest(
                "New Name",
                "new-avatar.png",
                "new_username"
        );

        when(userRepository.findByEmail(TEST_EMAIL)).thenReturn(Optional.of(mockUser));
        when(userSettingsRepository.findById(USER_ID)).thenReturn(Optional.of(mockSettings));
        when(userRepository.save(any(User.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserProfileResponse response = userService.updateProfile(TEST_EMAIL, request);

        // Assert
        assertEquals("New Name", response.displayName());
        assertEquals("new_username", response.username());
        assertEquals("new-avatar.png", response.avatar());

        verify(userRepository).save(mockUser);
    }

    @Test
    @DisplayName("Should update settings fields correctly")
    void updateSettings_Success() {
        // Arrange
        LocalTime newTime = LocalTime.of(20, 0);
        UpdateSettingsRequest request = new UpdateSettingsRequest(
                newTime,
                "pt_BR",
                true,
                (short) 5,
                false,
                false,
                false
        );

        when(userRepository.findByEmail(TEST_EMAIL)).thenReturn(Optional.of(mockUser));
        when(userSettingsRepository.findById(USER_ID)).thenReturn(Optional.of(mockSettings));
        when(userSettingsRepository.save(any(UserSettings.class))).thenAnswer(invocation -> invocation.getArgument(0));

        // Act
        UserProfileResponse response = userService.updateSettings(TEST_EMAIL, request);

        // Assert
        assertEquals("pt_BR", response.settings().locale());
        assertEquals(newTime, response.settings().dailyNotificationTime());
        assertEquals((short) 5, response.settings().dailyChallengeLimit());
        assertFalse(response.settings().vibrationEnabled());

        verify(userSettingsRepository).save(mockSettings);
    }
}