package com.github.gildeonbs.strivexp.dto;

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
            List<UUID> categoryIds
    ) {}
}
