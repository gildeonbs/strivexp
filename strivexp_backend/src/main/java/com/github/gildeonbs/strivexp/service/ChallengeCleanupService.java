package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.model.enums.ChallengeStatus;
import com.github.gildeonbs.strivexp.repository.UserChallengeRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChallengeCleanupService {

    private final UserChallengeRepository userChallengeRepository;

    /**
     * Runs every day at 00:05 AM server time.
     * Marks all 'ASSIGNED' challenges from yesterday (or earlier) as 'FAILED'.
     */
    @Scheduled(cron = "0 5 0 * * ?")
    // @Scheduled(fixedRate = 60000) // Runs every minute for test
    @Transactional
    public void markPastChallengesAsFailed() {
        LocalDate today = LocalDate.now();
        log.info("Starting Daily Challenge Cleanup for date: {}", today);

        int updatedCount = userChallengeRepository.updateStatusForPastChallenges(
                ChallengeStatus.FAILED,   // New Status
                ChallengeStatus.ASSIGNED, // Old Status (Target)
                today                     // Cutoff Date (Strictly less than today)
        );

        log.info("Daily Cleanup Complete. Marked {} challenges as FAILED.", updatedCount);
    }
}