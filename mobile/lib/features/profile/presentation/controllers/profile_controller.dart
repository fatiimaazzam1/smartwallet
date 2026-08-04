import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/localization/app_locale_controller.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/update_user_profile_request_model.dart';
import '../../data/models/user_preferences_model.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

final class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required AppLocaleController localeController,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       _localeController = localeController;

  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final AppLocaleController _localeController;

  UserProfileModel? _profile;
  UserPreferencesModel? _preferences;
  AppException? _error;
  bool _isLoading = false;
  bool _isSavingProfile = false;
  bool _isSavingPreferences = false;
  bool _isLoggingOut = false;

  UserProfileModel? get profile => _profile;
  UserPreferencesModel? get preferences => _preferences;
  AppException? get error => _error;
  bool get isLoading => _isLoading;
  bool get isSavingProfile => _isSavingProfile;
  bool get isSavingPreferences => _isSavingPreferences;
  bool get isLoggingOut => _isLoggingOut;
  bool get hasLoaded => _profile != null && _preferences != null;

  Future<void> load({bool force = false}) async {
    if (_isLoading || (hasLoaded && !force)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _profileRepository.getCurrentUser(),
        _profileRepository.getPreferences(),
      ]);

      _profile = results[0] as UserProfileModel;
      _preferences = results[1] as UserPreferencesModel;

      await _localeController.setPreference(_preferences!.language);
    } on AppException catch (exception) {
      _error = exception;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    if (_isSavingProfile) {
      return false;
    }

    _isSavingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final UserProfileModel updated = await _profileRepository
          .updateCurrentUser(
            UpdateUserProfileRequestModel(
              firstName: firstName,
              lastName: lastName,
            ),
          );
      _profile = updated;
      return true;
    } on AppException catch (exception) {
      _error = exception;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updatePreferences(UserPreferencesModel value) async {
    if (_isSavingPreferences) {
      return false;
    }

    _isSavingPreferences = true;
    _error = null;
    notifyListeners();

    try {
      final UserPreferencesModel updated = await _profileRepository
          .updatePreferences(value);
      _preferences = updated;
      await _localeController.setPreference(updated.language);
      return true;
    } on AppException catch (exception) {
      _error = exception;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _isSavingPreferences = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    if (_isLoggingOut) {
      return false;
    }

    _isLoggingOut = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.logout();
      _profile = null;
      _preferences = null;
      return true;
    } on AppException catch (exception) {
      _error = exception;
      return false;
    } catch (_) {
      _error = const AppException(
        message: 'Something unexpected happened. Please try again.',
        type: AppExceptionType.unknown,
      );
      return false;
    } finally {
      _isLoggingOut = false;
      notifyListeners();
    }
  }

  void clearError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }
}
