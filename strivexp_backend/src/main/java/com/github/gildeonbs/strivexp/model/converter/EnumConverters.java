package com.github.gildeonbs.strivexp.model.converter;

import com.github.gildeonbs.strivexp.model.enums.*;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

public class EnumConverters {

    // 1. Define a Generic Base Converter to handle the logic once
    public abstract static class BaseEnumConverter<T extends Enum<T>> implements AttributeConverter<T, String> {
        private final Class<T> clazz;

        protected BaseEnumConverter(Class<T> clazz) {
            this.clazz = clazz;
        }

        @Override
        public String convertToDatabaseColumn(T attribute) {
            return (attribute == null) ? null : attribute.name().toLowerCase();
        }

        @Override
        public T convertToEntityAttribute(String dbData) {
            return (dbData == null) ? null : Enum.valueOf(clazz, dbData.toUpperCase());
        }
    }

    // 2. Concrete implementations are now just one-liners
    @Converter(autoApply = true)
    public static class ChallengeRecurrenceConverter extends BaseEnumConverter<ChallengeRecurrence> {
        public ChallengeRecurrenceConverter() { super(ChallengeRecurrence.class); }
    }

    @Converter(autoApply = true)
    public static class ChallengeStatusConverter extends BaseEnumConverter<ChallengeStatus> {
        public ChallengeStatusConverter() { super(ChallengeStatus.class); }
    }

    @Converter(autoApply = true)
    public static class PlatformTypeConverter extends BaseEnumConverter<PlatformType> {
        public PlatformTypeConverter() { super(PlatformType.class); }
    }
    
    @Converter(autoApply = true)
    public static class XpEventTypeConverter extends BaseEnumConverter<XpEventType> {
        public XpEventTypeConverter() { super(XpEventType.class); }
    }
}
