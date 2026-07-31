import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/models/message_response_model.dart';
import '../../data/models/password_reset_token_response_model.dart';
import '../../data/models/verify_password_reset_code_request_model.dart';
import '../../data/repositories/auth_repository.dart';

final class VerifyPasswordResetCodeController extends ChangeNotifier {
  VerifyPasswordResetCodeController({required AuthRepository authRepository})
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

  Future<PasswordResetTokenResponseModel?> verifyPasswordResetCode({
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
      final VerifyPasswordResetCodeRequestModel request =
          VerifyPasswordResetCodeRequestModel(email: email, code: code);

      return await _authRepository.verifyPasswordResetCode(request);
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

  Future<MessageResponseModel?> resendPasswordResetCode({
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
      final ForgotPasswordRequestModel request = ForgotPasswordRequestModel(
        email: email,
      );

      final MessageResponseModel response = await _authRepository
          .resendPasswordResetCode(request);

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
