import 'package:flutter/foundation.dart';

class ConfigService {
  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '', // Will be replaced with actual key
  );
  
  static const String _fcmServerKey = String.fromEnvironment(
    'FCM_SERVER_KEY',
    defaultValue: '',
  );
  
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  // API Keys
  static String get googleMapsApiKey {
    if (_googleMapsApiKey.isEmpty) {
      if (kDebugMode) {
        print('⚠️ Google Maps API key not configured. Please add to environment variables.');
      }
      return 'YOUR_GOOGLE_MAPS_API_KEY_HERE'; // Placeholder for development
    }
    return _googleMapsApiKey;
  }

  static String get fcmServerKey {
    if (_fcmServerKey.isEmpty) {
      if (kDebugMode) {
        print('⚠️ FCM Server key not configured. Please add to environment variables.');
      }
      return 'YOUR_FCM_SERVER_KEY_HERE'; // Placeholder for development
    }
    return _fcmServerKey;
  }

  // Environment checks
  static bool get isProduction => _environment == 'production';
  static bool get isDevelopment => _environment == 'development';
  static bool get isDebugMode => kDebugMode && isDevelopment;

  // API Endpoints
  static const String prayerTimesApiUrl = 'http://api.aladhan.com/v1';
  static const String quranApiUrl = 'https://api.quran.com/api/v4';
  
  // App Configuration
  static const String androidPackageName = 'com.meezan.prayer_quran';
  static const String iosBundleId = 'com.meezan.prayer-quran';
  static const String appVersion = '1.0.0';
  
  // Feature flags
  static bool get analyticsEnabled => isProduction;
  static bool get crashReportingEnabled => isProduction;
  static bool get debugLoggingEnabled => isDevelopment;

  // Notification configuration
  static const Duration notificationScheduleAdvance = Duration(minutes: 5);
  static const Duration locationTimeout = Duration(seconds: 15);
  static const Duration apiTimeout = Duration(seconds: 30);

  // Prayer times configuration
  static const int defaultCalculationMethod = 4; // ISNA
  static const String defaultMadhab = 'Hanafi';
  static const List<String> supportedLanguages = [
    'en', 'ar', 'ur', 'tr', 'fr', 'ms'
  ];

  // Map configuration
  static const double defaultLatitude = 21.3891; // Mecca
  static const double defaultLongitude = 39.8579; // Mecca
  static const double mapZoomLevel = 15.0;

  // Validation methods
  static bool get isConfigured {
    return googleMapsApiKey.isNotEmpty && 
           fcmServerKey.isNotEmpty &&
           googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE' &&
           fcmServerKey != 'YOUR_FCM_SERVER_KEY_HERE';
  }

  static String get configurationStatus {
    final issues = <String>[];
    
    if (googleMapsApiKey.isEmpty || googleMapsApiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      issues.add('Google Maps API key not configured');
    }
    
    if (fcmServerKey.isEmpty || fcmServerKey == 'YOUR_FCM_SERVER_KEY_HERE') {
      issues.add('FCM server key not configured');
    }
    
    if (issues.isEmpty) {
      return '✅ All API keys configured';
    } else {
      return '⚠️ Missing: ${issues.join(', ')}';
    }
  }

  // Initialize configuration
  static void initialize() {
    if (kDebugMode) {
      print('🔧 Meezan App Configuration:');
      print('   Environment: $_environment');
      print('   Debug Mode: $isDebugMode');
      print('   Configuration Status: $configurationStatus');
      print('   Package Name: $androidPackageName');
      print('   App Version: $appVersion');
    }
  }
}