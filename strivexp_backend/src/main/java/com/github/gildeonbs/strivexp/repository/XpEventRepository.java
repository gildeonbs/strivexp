package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.XpEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface XpEventRepository extends JpaRepository<XpEvent, UUID> {
    
    // Efficiently sum all XP for a user directly in the database
    @Query("SELECT SUM(x.amount) FROM XpEvent x WHERE x.user.id = :userId")
    Optional<Long> getTotalXpByUserId(UUID userId);
}
