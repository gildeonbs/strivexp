package com.github.gildeonbs.strivexp.model;

import com.github.gildeonbs.strivexp.model.enums.ChallengeStatus;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "user_challenges", 
       uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "challenge_id", "assigned_date"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserChallenge {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "challenge_id", nullable = false)
    private Challenge challenge;

    @Column(name = "assigned_date", nullable = false)
    private LocalDate assignedDate;

    @Column(name = "due_date")
    private LocalDate dueDate;

    @Enumerated(EnumType.STRING)
    @Column(columnDefinition = "challenge_status", nullable = false)
    @Builder.Default
    private ChallengeStatus status = ChallengeStatus.ASSIGNED;

    @Column(name = "completed_at")
    private Instant completedAt;

    @Column(name = "xp_awarded")
    @Builder.Default
    private Integer xpAwarded = 0;

    @Column(name = "attempt_count")
    @Builder.Default
    private Short attemptCount = 0;

    private String note;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
