package com.smartwallet.backend.preference.domain;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = false)
public class DateFormatPreferenceConverter
        implements AttributeConverter<DateFormatPreference, String> {

    @Override
    public String convertToDatabaseColumn(
            DateFormatPreference attribute
    ) {
        return attribute == null
                ? null
                : attribute.getDatabaseValue();
    }

    @Override
    public DateFormatPreference convertToEntityAttribute(
            String databaseValue
    ) {
        return databaseValue == null
                ? null
                : DateFormatPreference.fromDatabaseValue(databaseValue);
    }
}
