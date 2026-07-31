import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/resend_verification_code_request_model.dart';
import '../../data/models/resend_verification_code_response_model.dart';
import '../../data/models/verify_email_request_model.dart';
import '../../data/models/verify_email_response_model.dart';
import '../../data/repositories/auth_repository.dart';

final class VerifyEmailController extends ChangeNotifier {
  VerifyEmailController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isVerifying => _isVerifying;

  bool get isResending => _isResending;

  bool get isLoading => _isVerifying || _isResending;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  Future<VerifyEmailResponseModel?> verifyEmail({
    required String email,
    required String code,
  }) async {
    if (isLoading) {
      return null;
    }

    _isVerifying = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final VerifyEmailRequestModel request = VerifyEmailRequestModel(
        email: email,
        code: code,
      );

      return await _authRepository.verifyEmail(request);
    } on AppException catch (exception) {
      _errorMessage = exception.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something unexpected happened. Please try again.';
      return null;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<ResendVerificationCodeResponseModel?> resendVerificationCode({
    required String email,
  }) async {
    if (isLoading) {
      return null;
    }

    _isResending = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final ResendVerificationCodeRequestModel request =
          ResendVerificationCodeRequestModel(email: email);

      final ResendVerificationCodeResponseModel response = await _authRepository
          .resendVerificationCode(request);

      _successMessage = response.message;

      return response;
    } on AppException catch (exception) {
      _errorMessage = exception.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something unexpected happened. Please try again.';
      return null;
    } finally {
      _isResending = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    if (_errorMessage == null && _successMessage == null) {
      return;
    }

    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
