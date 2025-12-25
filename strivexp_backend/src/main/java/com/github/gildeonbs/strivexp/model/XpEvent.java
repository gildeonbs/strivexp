package com.github.gildeonbs.strivexp.model;

import com.github.gildeonbs.strivexp.model.enums.XpEventType;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "xp_events")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class XpEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private Integer amount;

    // Handled by your auto-applied EnumConverters
    @Column(columnDefinition = "xp_event_type", nullable = false)
    private XpEventType type;

    @Column(name = "reference_id")
    private UUID referenceId; // Points to ChallengeID, PurchaseID, etc.

    private String note;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private Instant createdAt;
}
