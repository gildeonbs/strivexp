package com.github.gildeonbs.strivexp.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;
import java.util.UUID;

public class CategoryDtos {

    public record CategoryResponse(
            UUID id,
            String code,
            String name,
            String description,
            String icon,
            boolean isSelected // Helper for UI to show checkboxes
    ) {}

    public record UpdatePreferencesRequest(

            @NotEmpty(message = "You must select at least one category")
            List<UUID> categoryIds
    ) {}
}
