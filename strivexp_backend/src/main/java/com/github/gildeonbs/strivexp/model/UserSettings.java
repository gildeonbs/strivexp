package com.github.gildeonbs.strivexp.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalTime;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_settings")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSettings {

    // The PK is also the FK to Users, so we use @MapsId
    @Id
    @Column(name = "user_id")
    private UUID userId;

    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "daily_notification_time")
    private LocalTime dailyNotificationTime;

    private String locale;

    @Column(name = "receive_marketing")
    @Builder.Default
    private Boolean receiveMarketing = false;

    @Column(name = "daily_challenge_limit")
    @Builder.Default
    private Short dailyChallengeLimit = 3;

    @Column(name = "vibration_enabled")
    @Builder.Default
    private Boolean vibrationEnabled = true;

    @Column(name = "motivational_messages_enabled")
    @Builder.Default
    private Boolean motivationalMessagesEnabled = true;

    @Column(name = "sound_effects_enabled")
    @Builder.Default
    private Boolean soundEffectsEnabled = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}

