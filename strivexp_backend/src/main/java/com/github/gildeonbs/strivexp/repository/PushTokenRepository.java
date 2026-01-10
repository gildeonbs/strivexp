package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.PushToken;
import com.github.gildeonbs.strivexp.model.enums.PlatformType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PushTokenRepository extends JpaRepository<PushToken, UUID> {
    Optional<PushToken> findByToken(String token);
    List<PushToken> findByUserIdAndIsActiveTrue(UUID userId);

    // For cleanup jobs later (remove old tokens)
    void deleteByLastSeenAtBefore(Instant date);
}