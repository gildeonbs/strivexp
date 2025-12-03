package com.github.gildeonbs.strivexp.repository;

import com.github.gildeonbs.strivexp.model.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

// Grouping interfaces in one file for concise display; 
// in IDE, create separate .java files for each.

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Optional<User> findByUsername(String username);
}
