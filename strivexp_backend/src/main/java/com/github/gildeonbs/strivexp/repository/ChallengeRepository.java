package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.*;
import com.github.gildeonbs.strivexp.model.enums.ChallengeRecurrence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface ChallengeRepository extends JpaRepository<Challenge, UUID> {
    List<Challenge> findByRecurrenceAndIsActiveTrue(ChallengeRecurrence recurrence);
}

