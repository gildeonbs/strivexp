package com.github.gildeonbs.strivexp.controller;

import com.github.gildeonbs.strivexp.dto.CategoryDtos.*;
import com.github.gildeonbs.strivexp.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    // GET /api/categories
    @GetMapping
    public ResponseEntity<List<CategoryResponse>> getAllCategories(Authentication authentication) {
        return ResponseEntity.ok(categoryService.getAllCategoriesWithSelection(authentication.getName()));
    }

    // PUT /api/categories/preferences
    @PutMapping("/preferences")
    public ResponseEntity<Void> updatePreferences(
            Authentication authentication,
            @RequestBody UpdatePreferencesRequest request) {
        categoryService.updatePreferences(authentication.getName(), request);
        return ResponseEntity.ok().build();
    }
}