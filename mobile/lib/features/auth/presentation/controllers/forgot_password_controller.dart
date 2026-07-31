import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/models/message_response_model.dart';
import '../../data/repositories/auth_repository.dart';

final class ForgotPasswordController extends ChangeNotifier {
  ForgotPasswordController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<MessageResponseModel?> forgotPassword({required String email}) async {
    if (_isLoading) {
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ForgotPasswordRequestModel request = ForgotPasswordRequestModel(
        email: email,
      );

      return await _authRepository.forgotPassword(request);
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
