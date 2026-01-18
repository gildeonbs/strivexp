package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface UserSettingsRepository extends JpaRepository<UserSettings, UUID> {

    UserSettings findByUserId(UUID userId);

}
