package com.smartwallet.backend.preference.domain;

import java.util.Arrays;

public enum DateFormatPreference {
    DD_MM_YYYY("DD/MM/YYYY"),
    MM_DD_YYYY("MM/DD/YYYY"),
    YYYY_MM_DD("YYYY-MM-DD");

    private final String databaseValue;

    DateFormatPreference(
            String databaseValue
    ) {
        this.databaseValue = databaseValue;
    }

    public String getDatabaseValue() {
        return databaseValue;
    }

    public static DateFormatPreference fromDatabaseValue(
            String databaseValue
    ) {
        return Arrays.stream(values())
                .filter(value -> value.databaseValue.equals(databaseValue))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Unsupported date format preference"
                ));
    }
}
