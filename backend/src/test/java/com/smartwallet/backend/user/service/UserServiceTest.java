package com.smartwallet.backend.user.service;

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

import com.smartwallet.backend.common.exception.CurrentUserNotFoundException;
import com.smartwallet.backend.user.domain.User;
import com.smartwallet.backend.user.dto.request.UpdateCurrentUserRequest;
import com.smartwallet.backend.user.dto.response.CurrentUserResponse;
import com.smartwallet.backend.user.repository.UserRepository;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepository);
    }

    @Test
    void updateCurrentUserUpdatesOnlyNames() {
        User user = new User(
                "Old",
                "Name",
                "user@example.com",
                "password-hash"
        );

        when(userRepository.findById(1L))
                .thenReturn(Optional.of(user));
        when(userRepository.save(user))
                .thenReturn(user);

        CurrentUserResponse response = userService.updateCurrentUser(
                1L,
                new UpdateCurrentUserRequest(
                        "  Fatima  ",
                        "  Azzam  "
                )
        );

        assertThat(response.firstName()).isEqualTo("Fatima");
        assertThat(response.lastName()).isEqualTo("Azzam");
        assertThat(response.email()).isEqualTo("user@example.com");
        verify(userRepository).save(user);
    }

    @Test
    void getCurrentUserRejectsMissingAuthenticatedAccount() {
        when(userRepository.findById(99L))
                .thenReturn(Optional.empty());

        assertThatThrownBy(() -> userService.getCurrentUser(99L))
                .isInstanceOf(CurrentUserNotFoundException.class);
    }
}
