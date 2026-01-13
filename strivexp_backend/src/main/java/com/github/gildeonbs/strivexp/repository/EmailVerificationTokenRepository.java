package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.EmailVerificationToken;
import com.github.gildeonbs.strivexp.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationToken, UUID> {
    Optional<EmailVerificationToken> findByUser(User user);
}

