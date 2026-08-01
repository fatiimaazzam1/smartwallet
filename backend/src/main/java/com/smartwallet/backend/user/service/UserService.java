package com.smartwallet.backend.user.service;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.smartwallet.backend.common.exception.CurrentUserNotFoundException;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.dto.request.UpdateCurrentUserRequest;
import com.smartwallet.backend.user.dto.response.CurrentUserResponse;
import com.smartwallet.backend.user.repository.UserRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public CurrentUserResponse getCurrentUser(
            Long currentUserId
    ) {
        User user = findCurrentUser(currentUserId);
        return toResponse(user);
    }

    @Transactional
    public CurrentUserResponse updateCurrentUser(
            Long currentUserId,
            UpdateCurrentUserRequest request
    ) {
        User user = findCurrentUser(currentUserId);

        user.setFirstName(normalizeName(request.firstName()));
        user.setLastName(normalizeName(request.lastName()));

        return toResponse(userRepository.save(user));
    }

    private User findCurrentUser(
            Long currentUserId
    ) {
        return userRepository.findById(currentUserId)
                .orElseThrow(CurrentUserNotFoundException::new);
    }

    private String normalizeName(
            String value
    ) {
        return value.strip().replaceAll("[\\p{Zs}\\s]+", " ");
    }

    private CurrentUserResponse toResponse(
            User user
    ) {
        return new CurrentUserResponse(
                user.getId(),
                user.getFirstName(),
                user.getLastName(),
                user.getEmail()
        );
    }
}
