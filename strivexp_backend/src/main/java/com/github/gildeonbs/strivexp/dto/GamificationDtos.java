package com.github.gildeonbs.strivexp.dto;

public class GamificationDtos {

    public record UserProgressDto(
        Integer level,
        Long currentXp,
        Long xpForNextLevel,
        Long xpInCurrentLevel, // XP earned towards the next level
        Double progressPercentage // 0.0 to 1.0 for progress bar
    ) {}
    
    public record XpAwardedEvent(
        Integer amount,
        String source,
        Integer newLevel,
        boolean levelUpOccurred
    ) {}
}
