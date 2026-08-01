package com.smartwallet.backend.preference.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import com.smartwallet.backend.preference.domain.AppLanguage;
import com.smartwallet.backend.preference.domain.DashboardPeriod;
import com.smartwallet.backend.preference.domain.DateFormatPreference;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.preference.dto.request.UpdateUserPreferenceRequest;
import com.smartwallet.backend.preference.dto.response.UserPreferenceResponse;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
class UserPreferenceServiceTest {

    @Mock
    private UserPreferenceRepository userPreferenceRepository;

    @Mock
    private UserRepository userRepository;

    private UserPreferenceService userPreferenceService;

    @BeforeEach
    void setUp() {
        userPreferenceService = new UserPreferenceService(
                userPreferenceRepository,
                userRepository
        );
    }

    @Test
    void updatePreferencesPersistsControlledValues() {
        User user = new User(
                "Fatima",
                "Azzam",
                "user@example.com",
                "password-hash"
        );
        UserPreference preference = new UserPreference(user);

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(userPreferenceRepository.findByUserId(1L))
                .thenReturn(Optional.of(preference));
        when(userPreferenceRepository.save(preference))
                .thenReturn(preference);

        UserPreferenceResponse response =
                userPreferenceService.updateCurrentUserPreferences(
                        1L,
                        new UpdateUserPreferenceRequest(
                                true,
                                true,
                                true,
                                80,
                                DateFormatPreference.YYYY_MM_DD,
                                DashboardPeriod.LAST_30_DAYS,
                                AppLanguage.ARABIC
                        )
                );

        assertThat(response.hideBalanceByDefault()).isTrue();
        assertThat(response.compactTransactionList()).isTrue();
        assertThat(response.budgetWarningThreshold()).isEqualTo(80);
        assertThat(response.dateFormat())
                .isEqualTo(DateFormatPreference.YYYY_MM_DD);
        assertThat(response.dashboardPeriod())
                .isEqualTo(DashboardPeriod.LAST_30_DAYS);
        assertThat(response.language()).isEqualTo(AppLanguage.ARABIC);
        verify(userPreferenceRepository).save(preference);
    }

    @Test
    void updatePreferencesRejectsUnsupportedWarningThreshold() {
        assertThatThrownBy(() ->
                userPreferenceService.updateCurrentUserPreferences(
                        1L,
                        new UpdateUserPreferenceRequest(
                                false,
                                false,
                                true,
                                75,
                                DateFormatPreference.DD_MM_YYYY,
                                DashboardPeriod.CURRENT_MONTH,
                                AppLanguage.SYSTEM
                        )
                )
        )
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Budget warning threshold must be 70, 80, or 90");
    }
}
