package com.smartwallet.backend.auth.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartwallet.backend.auth.domain.EmailActionCode;
import com.smartwallet.backend.auth.domain.EmailActionPurpose;
import com.smartwallet.backend.user.domain.User;

public interface EmailActionCodeRepository
        extends JpaRepository<EmailActionCode, Long> {

    Optional<EmailActionCode>
            findFirstByUserAndPurposeAndInvalidatedAtIsNullAndUsedAtIsNullOrderByCreatedAtDesc(
                    User user,
                    EmailActionPurpose purpose);

    Optional<EmailActionCode>
            findByActionTokenHashAndPurposeAndInvalidatedAtIsNullAndUsedAtIsNull(
                    String actionTokenHash,
                    EmailActionPurpose purpose);
}