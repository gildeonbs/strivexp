package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.PasswordResetToken;
import com.github.gildeonbs.strivexp.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.UUID;

@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, UUID> {

    // Used for Rate Limiting: Count how many requests this user made recently
    long countByUserAndCreatedAtAfter(User user, Instant since);
}