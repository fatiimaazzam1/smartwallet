import 'package:flutter/material.dart';
import 'package:smartwallet_mobile/l10n/l10n.dart';

import 'app_exception.dart';

abstract final class LocalizedErrorMessage {
  LocalizedErrorMessage._();

  static String fromMessage(BuildContext context, String? rawMessage) {
    final AppLocalizations l10n = context.l10n;
    final String normalized = (rawMessage ?? '').trim().toLowerCase();

    if (normalized.isEmpty) {
      return l10n.genericError;
    }

    final String? knownMessage = _knownMessage(l10n, normalized);
    return knownMessage ?? l10n.genericError;
  }

  static String fromException(BuildContext context, AppException? exception) {
    final AppLocalizations l10n = context.l10n;

    if (exception == null) {
      return l10n.genericError;
    }

    final String normalized = exception.message.trim().toLowerCase();
    final String? knownMessage = _knownMessage(l10n, normalized);

    if (knownMessage != null) {
      return knownMessage;
    }

    switch (exception.type) {
      case AppExceptionType.validation:
        return l10n.validationError;
      case AppExceptionType.unauthorized:
        return l10n.unauthorizedError;
      case AppExceptionType.forbidden:
        return l10n.forbiddenError;
      case AppExceptionType.conflict:
        return l10n.conflictError;
      case AppExceptionType.network:
        return l10n.networkError;
      case AppExceptionType.timeout:
        return l10n.timeoutError;
      case AppExceptionType.server:
        return l10n.serverError;
      case AppExceptionType.unknown:
        return l10n.genericError;
    }
  }

  static String? _knownMessage(
    AppLocalizations l10n,
    String normalized,
  ) {
    if (normalized.contains('invalid credentials') ||
        normalized.contains('incorrect email') ||
        normalized.contains('invalid email or password') ||
        normalized.contains('email or password is incorrect')) {
      return l10n.invalidCredentialsError;
    }

    if (normalized.contains('account disabled') ||
        normalized.contains('account is disabled')) {
      return l10n.accountDisabledError;
    }

    if (normalized.contains('already registered') ||
        normalized.contains('email already exists') ||
        normalized.contains('account already exists')) {
      return l10n.emailAlreadyRegisteredError;
    }

    if (normalized.contains('too many') &&
        (normalized.contains('attempt') || normalized.contains('failed'))) {
      return l10n.tooManyAttemptsError;
    }

    if (normalized.contains('cooldown') ||
        normalized.contains('wait before') ||
        normalized.contains('try again in')) {
      return l10n.cooldownError;
    }

    if ((normalized.contains('code') || normalized.contains('token')) &&
        (normalized.contains('invalid') ||
            normalized.contains('expired') ||
            normalized.contains('incorrect') ||
            normalized.contains('used'))) {
      return l10n.invalidOrExpiredCodeError;
    }

    if (normalized.contains('could not restore your session')) {
      return l10n.restoreSessionError;
    }

    if (normalized.contains('invalid server response')) {
      return l10n.invalidServerResponseError;
    }

    if (normalized.contains('securely save') ||
        normalized.contains('securely restore') ||
        normalized.contains('securely clear') ||
        normalized.contains('secure storage')) {
      return l10n.secureStorageError;
    }

    if (normalized.contains('cancelled') || normalized.contains('canceled')) {
      return l10n.requestCancelledError;
    }

    if (normalized.contains('too long') || normalized.contains('timeout')) {
      return l10n.timeoutError;
    }

    if (normalized.contains('connect') ||
        normalized.contains('internet') ||
        normalized.contains('network') ||
        normalized.contains('certificate')) {
      return l10n.networkError;
    }

    if (normalized.contains('authentication') ||
        normalized.contains('unauthorized') ||
        normalized.contains('session')) {
      return l10n.unauthorizedError;
    }

    if (normalized.contains('not allowed') ||
        normalized.contains('forbidden')) {
      return l10n.forbiddenError;
    }

    if (normalized.contains('conflict')) {
      return l10n.conflictError;
    }

    if (normalized.contains('temporarily unavailable') ||
        normalized.contains('server')) {
      return l10n.serverError;
    }

    if (normalized.contains('invalid') ||
        normalized.contains('required') ||
        normalized.contains('submitted information') ||
        normalized.contains('malformed json')) {
      return l10n.validationError;
    }

    return null;
  }
}
