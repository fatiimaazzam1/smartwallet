import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/message_response_model.dart';
import '../../data/models/reset_password_request_model.dart';
import '../../data/repositories/auth_repository.dart';

final class ResetPasswordController extends ChangeNotifier {
  ResetPasswordController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<MessageResponseModel?> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_isLoading) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ResetPasswordRequestModel request = ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      return await _authRepository.resetPassword(request);
    } on AppException catch (exception) {
      _errorMessage = exception.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something unexpected happened. Please try again.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }
}
