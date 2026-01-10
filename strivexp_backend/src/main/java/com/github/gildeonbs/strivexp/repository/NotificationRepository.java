package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.Notification;
import com.github.gildeonbs.strivexp.model.enums.PlatformType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    List<Notification> findByUserIdOrderByCreatedAtDesc(UUID userId);
}