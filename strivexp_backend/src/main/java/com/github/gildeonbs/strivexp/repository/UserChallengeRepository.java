package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.*;
import com.github.gildeonbs.strivexp.model.enums.ChallengeStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserChallengeRepository extends JpaRepository<UserChallenge, UUID> {
    
    // Find all active challenges for a user on a specific date
    List<UserChallenge> findByUserIdAndAssignedDate(UUID userId, LocalDate date);

    // Find specific assignment to prevent duplicates
    Optional<UserChallenge> findByUserIdAndChallengeIdAndAssignedDate(UUID userId, UUID challengeId, LocalDate assignedDate);
    
    // Find incomplete challenges for today
    @Query("SELECT uc FROM UserChallenge uc WHERE uc.user.id = :userId AND uc.assignedDate = :date AND uc.status = 'ASSIGNED'")
    List<UserChallenge> findPendingForUser(@Param("userId") UUID userId, @Param("date") LocalDate date);

    // Bulk Update for FAILED status ---
    @Modifying // Required for UPDATE/DELETE queries
    @Query("UPDATE UserChallenge uc SET uc.status = :newStatus WHERE uc.status = :oldStatus AND uc.assignedDate < :today")
    int updateStatusForPastChallenges(
            @Param("newStatus") ChallengeStatus newStatus,
            @Param("oldStatus") ChallengeStatus oldStatus,
            @Param("today") LocalDate today
    );

    // Used for count skips for today
    long countByUserIdAndAssignedDateAndStatus(UUID userId, LocalDate assignedDate, ChallengeStatus status);

}
