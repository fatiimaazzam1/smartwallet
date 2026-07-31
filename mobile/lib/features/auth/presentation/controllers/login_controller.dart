import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/login_request_model.dart';
import '../../data/repositories/auth_repository.dart';

enum LoginSubmissionResult { success, emailVerificationRequired, failure }

final class LoginController extends ChangeNotifier {
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<LoginSubmissionResult> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return LoginSubmissionResult.failure;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final LoginRequestModel request = LoginRequestModel(
        email: email,
        password: password,
      );

      await _authRepository.login(request);

      return LoginSubmissionResult.success;
    } on AppException catch (exception) {
      if (exception.statusCode == 403) {
        return LoginSubmissionResult.emailVerificationRequired;
      }

      _errorMessage = exception.message;

      return LoginSubmissionResult.failure;
    } catch (_) {
      _errorMessage = 'Something unexpected happened. Please try again.';

      return LoginSubmissionResult.failure;
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
