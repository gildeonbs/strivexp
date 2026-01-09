package com.github.gildeonbs.strivexp.service;

import com.github.gildeonbs.strivexp.dto.CategoryDtos.*;
import com.github.gildeonbs.strivexp.exception.CustomExceptions.ResourceNotFoundException;
import com.github.gildeonbs.strivexp.model.Category;
import com.github.gildeonbs.strivexp.model.User;
import com.github.gildeonbs.strivexp.model.UserCategory;
import com.github.gildeonbs.strivexp.model.UserCategoryId;
import com.github.gildeonbs.strivexp.repository.CategoryRepository;
import com.github.gildeonbs.strivexp.repository.UserCategoryRepository;
import com.github.gildeonbs.strivexp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;
    private final UserCategoryRepository userCategoryRepository;
    private final UserRepository userRepository;

    /**
     * Returns all categories with a flag indicating if the user has selected them.
     */
    @Transactional(readOnly = true)
    public List<CategoryResponse> getAllCategoriesWithSelection(String userEmail) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        List<Category> allCategories = categoryRepository.findAll();
        Set<UUID> userCategoryIds = Set.copyOf(userCategoryRepository.findCategoryIdsByUserId(user.getId()));

        return allCategories.stream()
                .map(c -> new CategoryResponse(
                        c.getId(),
                        c.getCode(),
                        c.getName(),
                        c.getDescription(),
                        c.getIcon(),
                        userCategoryIds.contains(c.getId())
                ))
                .collect(Collectors.toList());
    }

    /**
     * Overwrites the user's category preferences.
     */
    @Transactional
    public void updatePreferences(String userEmail, UpdatePreferencesRequest request) {
        User user = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        // 1. Clear existing preferences
        userCategoryRepository.deleteAllByUserId(user.getId());

        // 2. Add new preferences
        if (request.categoryIds() != null && !request.categoryIds().isEmpty()) {
            List<UserCategory> newPreferences = request.categoryIds().stream()
                    .map(categoryId -> {
                        Category cat = categoryRepository.getReferenceById(categoryId); // Proxy reference is efficient
                        return UserCategory.builder()
                                .id(new UserCategoryId(user.getId(), categoryId))
                                .user(user)
                                .category(cat)
                                .build();
                    })
                    .collect(Collectors.toList());

            userCategoryRepository.saveAll(newPreferences);
        }
    }
}