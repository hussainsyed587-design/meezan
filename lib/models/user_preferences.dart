
import 'package:flutter/material.dart';

class UserPreferences {
  final String language;
  final String madhab;
  final int calculationMethod;
  final bool notificationsEnabled;
  final bool athanEnabled;
  final String athanSound;
  final bool vibrateOnNotification;
  final ThemeMode themeMode;
  final double fontSize;
  final bool locationPermissionGranted;
  final bool onboardingCompleted;
  
  UserPreferences({
    this.language = 'en',
    this.madhab = 'Hanafi',
    this.calculationMethod = 4,
    this.notificationsEnabled = true,
    this.athanEnabled = true,
    this.athanSound = 'default',
    this.vibrateOnNotification = true,
    this.themeMode = ThemeMode.system,
    this.fontSize = 16.0,
    this.locationPermissionGranted = false,
    this.onboardingCompleted = false,
  });
  
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'en',
      madhab: json['madhab'] ?? 'Hanafi',
      calculationMethod: json['calculationMethod'] ?? 4,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      athanEnabled: json['athanEnabled'] ?? true,
      athanSound: json['athanSound'] ?? 'default',
      vibrateOnNotification: json['vibrateOnNotification'] ?? true,
      themeMode: _themeModeFromString(json['themeMode']),
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      locationPermissionGranted: json['locationPermissionGranted'] ?? false,
      onboardingCompleted: json['onboardingCompleted'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'madhab': madhab,
      'calculationMethod': calculationMethod,
      'notificationsEnabled': notificationsEnabled,
      'athanEnabled': athanEnabled,
      'athanSound': athanSound,
      'vibrateOnNotification': vibrateOnNotification,
      'themeMode': themeMode.toString(),
      'fontSize': fontSize,
      'locationPermissionGranted': locationPermissionGranted,
      'onboardingCompleted': onboardingCompleted,
    };
  }
  
  UserPreferences copyWith({
    String? language,
    String? madhab,
    int? calculationMethod,
    bool? notificationsEnabled,
    bool? athanEnabled,
    String? athanSound,
    bool? vibrateOnNotification,
    ThemeMode? themeMode,
    double? fontSize,
    bool? locationPermissionGranted,
    bool? onboardingCompleted,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      madhab: madhab ?? this.madhab,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      athanEnabled: athanEnabled ?? this.athanEnabled,
      athanSound: athanSound ?? this.athanSound,
      vibrateOnNotification: vibrateOnNotification ?? this.vibrateOnNotification,
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
  
  static ThemeMode _themeModeFromString(String? value) {
    switch (value) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
      default:
        return ThemeMode.system;
    }
  }
  
  bool get isDarkMode {
    return themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode {
    return themeMode == ThemeMode.light;
  }
  
  bool get isSystemMode {
    return themeMode == ThemeMode.system;
  }
}