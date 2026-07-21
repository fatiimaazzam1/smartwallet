package com.smartwallet.backend.auth.domain;

import java.time.LocalDateTime;

import com.smartwallet.backend.common.domain.BaseEntity;
import com.smartwallet.backend.user.domain.User;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "email_action_codes")
@Getter
@Setter
@NoArgsConstructor
public class EmailActionCode extends BaseEntity {

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "purpose", nullable = false, length = 30)
    private EmailActionPurpose purpose;

    @Column(name = "code_hash", nullable = false, length = 255)
    private String codeHash;

    @Column(name = "expires_at", nullable = false)
    private LocalDateTime expiresAt;

    @Column(name = "resend_available_at", nullable = false)
    private LocalDateTime resendAvailableAt;

    @Column(name = "failed_attempts", nullable = false)
    private int failedAttempts;

    @Column(name = "verified_at")
    private LocalDateTime verifiedAt;

    @Column(name = "action_token_hash", length = 255)
    private String actionTokenHash;

    @Column(name = "action_token_expires_at")
    private LocalDateTime actionTokenExpiresAt;

    @Column(name = "invalidated_at")
    private LocalDateTime invalidatedAt;

    @Column(name = "used_at")
    private LocalDateTime usedAt;

    public EmailActionCode(
            User user,
            EmailActionPurpose purpose,
            String codeHash,
            LocalDateTime expiresAt,
            LocalDateTime resendAvailableAt) {

        this.user = user;
        this.purpose = purpose;
        this.codeHash = codeHash;
        this.expiresAt = expiresAt;
        this.resendAvailableAt = resendAvailableAt;
        this.failedAttempts = 0;
    }
}