package com.smartwallet.backend.preference.service;

import java.util.Set;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.common.exception.CurrentUserNotFoundException;
import com.smartwallet.backend.preference.domain.UserPreference;
import com.smartwallet.backend.preference.dto.request.UpdateUserPreferenceRequest;
import com.smartwallet.backend.preference.dto.response.UserPreferenceResponse;
import com.smartwallet.backend.preference.repository.UserPreferenceRepository;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserPreferenceService {

    private static final Set<Integer> ALLOWED_WARNING_THRESHOLDS =
            Set.of(70, 80, 90);

    private final UserPreferenceRepository userPreferenceRepository;
    private final UserRepository userRepository;

    @Transactional
    public UserPreferenceResponse getCurrentUserPreferences(
            Long currentUserId
    ) {
        User user = findCurrentUser(currentUserId);
        UserPreference preference = findOrCreatePreference(
                currentUserId,
                user
        );
        return toResponse(preference);
    }

    @Transactional
    public UserPreferenceResponse updateCurrentUserPreferences(
            Long currentUserId,
            UpdateUserPreferenceRequest request
    ) {
        validateWarningThreshold(request.budgetWarningThreshold());

        User user = findCurrentUser(currentUserId);
        UserPreference preference = findOrCreatePreference(
                currentUserId,
                user
        );

        preference.setHideBalanceByDefault(
                request.hideBalanceByDefault()
        );
        preference.setCompactTransactionList(
                request.compactTransactionList()
        );
        preference.setShowBudgetWarnings(
                request.showBudgetWarnings()
        );
        preference.setBudgetWarningThreshold(
                request.budgetWarningThreshold()
        );
        preference.setDateFormat(request.dateFormat());
        preference.setDashboardPeriod(request.dashboardPeriod());
        preference.setLanguage(request.language());

        return toResponse(
                userPreferenceRepository.save(preference)
        );
    }

    private User findCurrentUser(
            Long currentUserId
    ) {
        return userRepository.findById(currentUserId)
                .orElseThrow(CurrentUserNotFoundException::new);
    }

    private UserPreference findOrCreatePreference(
            Long currentUserId,
            User user
    ) {
        return userPreferenceRepository.findByUserId(currentUserId)
                .orElseGet(() -> userPreferenceRepository.save(
                        new UserPreference(user)
                ));
    }

    private void validateWarningThreshold(
            Integer threshold
    ) {
        if (!ALLOWED_WARNING_THRESHOLDS.contains(threshold)) {
            throw new IllegalArgumentException(
                    "Budget warning threshold must be 70, 80, or 90"
            );
        }
    }

    private UserPreferenceResponse toResponse(
            UserPreference preference
    ) {
        return new UserPreferenceResponse(
                preference.isHideBalanceByDefault(),
                preference.isCompactTransactionList(),
                preference.isShowBudgetWarnings(),
                preference.getBudgetWarningThreshold(),
                preference.getDateFormat(),
                preference.getDashboardPeriod(),
                preference.getLanguage()
        );
    }
}
