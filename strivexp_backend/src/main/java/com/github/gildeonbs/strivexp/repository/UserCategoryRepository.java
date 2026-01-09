package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.UserCategory;
import com.github.gildeonbs.strivexp.model.UserCategoryId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface UserCategoryRepository extends JpaRepository<UserCategory, UserCategoryId> {

    // Find all category IDs selected by a user
    @Query("SELECT uc.id.categoryId FROM UserCategory uc WHERE uc.id.userId = :userId")
    List<UUID> findCategoryIdsByUserId(UUID userId);

    // Bulk delete for updating preferences (cleanest way to handle 'sync')
    @Modifying
    @Query("DELETE FROM UserCategory uc WHERE uc.id.userId = :userId")
    void deleteAllByUserId(UUID userId);
}