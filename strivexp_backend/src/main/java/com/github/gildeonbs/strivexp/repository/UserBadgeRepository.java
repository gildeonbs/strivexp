package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.Badge;
import com.github.gildeonbs.strivexp.model.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserBadgeRepository extends JpaRepository<UserBadge, UUID> {
    
    boolean existsByUserIdAndBadgeCode(UUID userId, String badgeCode);
    
    @Query("SELECT ub.badge FROM UserBadge ub WHERE ub.user.id = :userId")
    List<Badge> findBadgesByUserId(UUID userId);

    // Updated: Fetch the relationship entity to get 'awardedAt'
    // Uses Entity Graph (optional optimization) or standard join
    List<UserBadge> findByUserId(UUID userId);

}
