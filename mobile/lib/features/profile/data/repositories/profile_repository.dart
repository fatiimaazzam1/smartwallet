import '../datasources/profile_remote_data_source.dart';
import '../models/update_user_profile_request_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_profile_model.dart';

final class ProfileRepository {
  const ProfileRepository({required ProfileRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final ProfileRemoteDataSource _remoteDataSource;

  Future<UserProfileModel> getCurrentUser() {
    return _remoteDataSource.getCurrentUser();
  }

  Future<UserProfileModel> updateCurrentUser(
    UpdateUserProfileRequestModel request,
  ) {
    return _remoteDataSource.updateCurrentUser(request);
  }

  Future<UserPreferencesModel> getPreferences() {
    return _remoteDataSource.getPreferences();
  }

  Future<UserPreferencesModel> updatePreferences(
    UserPreferencesModel preferences,
  ) {
    return _remoteDataSource.updatePreferences(preferences);
  }
}
