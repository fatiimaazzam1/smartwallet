import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  OnboardingStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  final SharedPreferencesAsync _preferences;

  Future<bool> hasSeenOnboarding() async {
    return await _preferences.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> markOnboardingAsSeen() async {
    await _preferences.setBool(_hasSeenOnboardingKey, true);
  }
}
