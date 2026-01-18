package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.RefreshToken;
import com.github.gildeonbs.strivexp.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);
    
    // Useful for "Logout all devices" functionality
    List<RefreshToken> findAllByUser(User user);
}
