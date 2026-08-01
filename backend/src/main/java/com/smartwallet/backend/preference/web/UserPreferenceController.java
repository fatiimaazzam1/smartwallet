package com.smartwallet.backend.preference.web;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.preference.dto.request.UpdateUserPreferenceRequest;
import com.smartwallet.backend.preference.dto.response.UserPreferenceResponse;
import com.smartwallet.backend.preference.service.UserPreferenceService;
import com.smartwallet.backend.user.domain.User;

import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/users/me/preferences")
@RequiredArgsConstructor
@SecurityRequirement(name = "bearerAuth")
public class UserPreferenceController {

    private final UserPreferenceService userPreferenceService;

    @GetMapping
    public ResponseEntity<UserPreferenceResponse> getPreferences(
            @AuthenticationPrincipal User currentUser
    ) {
        return ResponseEntity.ok(
                userPreferenceService.getCurrentUserPreferences(
                        currentUser.getId()
                )
        );
    }

    @PutMapping
    public ResponseEntity<UserPreferenceResponse> updatePreferences(
            @AuthenticationPrincipal User currentUser,
            @Valid @RequestBody UpdateUserPreferenceRequest request
    ) {
        return ResponseEntity.ok(
                userPreferenceService.updateCurrentUserPreferences(
                        currentUser.getId(),
                        request
                )
        );
    }
}
