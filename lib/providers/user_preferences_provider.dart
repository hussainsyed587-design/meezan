import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences.dart';
import '../constants/app_constants.dart';

class UserPreferencesProvider extends ChangeNotifier {
  UserPreferences _preferences = UserPreferences();
  SharedPreferences? _prefs;
  
  UserPreferences get preferences => _preferences;
  
  UserPreferencesProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    
    _preferences = UserPreferences(
      language: _prefs?.getString(AppConstants.selectedLanguageKey) ?? 'en',
      madhab: _prefs?.getString(AppConstants.selectedMadhabKey) ?? AppConstants.defaultMadhab,
      calculationMethod: _prefs?.getInt(AppConstants.selectedMethodKey) ?? AppConstants.defaultCalculationMethod,
      notificationsEnabled: _prefs?.getBool('${AppConstants.notificationPrefsKey}_enabled') ?? true,
      athanEnabled: _prefs?.getBool('${AppConstants.notificationPrefsKey}_athan') ?? true,
      athanSound: _prefs?.getString('${AppConstants.notificationPrefsKey}_sound') ?? 'default',
      vibrateOnNotification: _prefs?.getBool('${AppConstants.notificationPrefsKey}_vibrate') ?? true,
      themeMode: _getThemeMode(_prefs?.getString(AppConstants.themePreferenceKey)),
      fontSize: _prefs?.getDouble('font_size') ?? 16.0,
      locationPermissionGranted: _prefs?.getBool('location_permission') ?? false,
      onboardingCompleted: _prefs?.getBool(AppConstants.onboardingCompletedKey) ?? false,
    );
    
    notifyListeners();
  }
  
  ThemeMode _getThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  Future<void> updateLanguage(String language) async {
    _preferences = _preferences.copyWith(language: language);
    await _prefs?.setString(AppConstants.selectedLanguageKey, language);
    notifyListeners();
  }
  
  Future<void> updateMadhab(String madhab) async {
    _preferences = _preferences.copyWith(madhab: madhab);
    await _prefs?.setString(AppConstants.selectedMadhabKey, madhab);
    notifyListeners();
  }
  
  Future<void> updateCalculationMethod(int method) async {
    _preferences = _preferences.copyWith(calculationMethod: method);
    await _prefs?.setInt(AppConstants.selectedMethodKey, method);
    notifyListeners();
  }
  
  Future<void> updateNotificationSettings({
    bool? enabled,
    bool? athanEnabled,
    String? athanSound,
    bool? vibrate,
  }) async {
    _preferences = _preferences.copyWith(
      notificationsEnabled: enabled ?? _preferences.notificationsEnabled,
      athanEnabled: athanEnabled ?? _preferences.athanEnabled,
      athanSound: athanSound ?? _preferences.athanSound,
      vibrateOnNotification: vibrate ?? _preferences.vibrateOnNotification,
    );
    
    if (enabled != null) {
      await _prefs?.setBool('${AppConstants.notificationPrefsKey}_enabled', enabled);
    }
    if (athanEnabled != null) {
      await _prefs?.setBool('${AppConstants.notificationPrefsKey}_athan', athanEnabled);
    }
    if (athanSound != null) {
      await _prefs?.setString('${AppConstants.notificationPrefsKey}_sound', athanSound);
    }
    if (vibrate != null) {
      await _prefs?.setBool('${AppConstants.notificationPrefsKey}_vibrate', vibrate);
    }
    
    notifyListeners();
  }
  
  Future<void> updateThemeMode(ThemeMode mode) async {
    _preferences = _preferences.copyWith(themeMode: mode);
    await _prefs?.setString(AppConstants.themePreferenceKey, _themeModeToString(mode));
    notifyListeners();
  }
  
  Future<void> updateFontSize(double fontSize) async {
    _preferences = _preferences.copyWith(fontSize: fontSize);
    await _prefs?.setDouble('font_size', fontSize);
    notifyListeners();
  }
  
  Future<void> updateLocationPermission(bool granted) async {
    _preferences = _preferences.copyWith(locationPermissionGranted: granted);
    await _prefs?.setBool('location_permission', granted);
    notifyListeners();
  }
  
  Future<void> completeOnboarding() async {
    _preferences = _preferences.copyWith(onboardingCompleted: true);
    await _prefs?.setBool(AppConstants.onboardingCompletedKey, true);
    notifyListeners();
  }
  
  Future<void> resetPreferences() async {
    await _prefs?.clear();
    _preferences = UserPreferences();
    notifyListeners();
  }
}