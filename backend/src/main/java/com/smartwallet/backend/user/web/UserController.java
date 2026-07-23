package com.smartwallet.backend.user.web;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.dto.response.CurrentUserResponse;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @GetMapping("/me")
    public ResponseEntity<CurrentUserResponse> getCurrentUser(
            @AuthenticationPrincipal User currentUser
    ) {

        CurrentUserResponse response =
                new CurrentUserResponse(
                        currentUser.getId(),
                        currentUser.getFirstName(),
                        currentUser.getLastName(),
                        currentUser.getEmail()
                );

        return ResponseEntity.ok(response);
    }
}