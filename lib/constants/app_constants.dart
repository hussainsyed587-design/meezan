class AppConstants {
  // App Info
  static const String appName = 'Meezan';
  static const String appFullName = 'Meezan: Prayer & Quran';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Complete Islamic lifestyle companion app';
  
  // API Endpoints
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';
  static const String quranApiUrl = 'https://api.alquran.cloud/v1';
  static const String hadithApiUrl = 'https://api.sunnah.com/v1';
  
  // Prayer Times Calculation Methods
  static const Map<String, int> prayerMethods = {
    'Muslim World League': 3,
    'Islamic Society of North America (ISNA)': 2,
    'Egyptian General Authority of Survey': 5,
    'Umm Al-Qura University, Makkah': 4,
    'University of Islamic Sciences, Karachi': 1,
    'Institute of Geophysics, University of Tehran': 7,
    'Shia Ithna-Ashari, Leva Institute, Qum': 0,
    'Gulf Region': 8,
    'Kuwait': 9,
    'Qatar': 10,
    'Majlis Ugama Islam Singapura, Singapore': 11,
    'Union Organization islamic de France': 12,
    'Diyanet İşleri Başkanlığı, Turkey': 13,
    'Spiritual Administration of Muslims of Russia': 14,
  };
  
  // Madhabs
  static const List<String> madhabs = [
    'Hanafi',
    'Shafi\'i',
    'Maliki',
    'Hanbali',
  ];
  
  // Prayer Names
  static const List<String> prayerNames = [
    'Fajr',
    'Dhuhr', 
    'Asr',
    'Maghrib',
    'Isha'
  ];
  
  // Islamic Calendar Events
  static const Map<String, String> islamicEvents = {
    '1/1': 'Islamic New Year',
    '1/10': 'Day of Ashura',
    '3/12': 'Mawlid an-Nabi',
    '7/27': 'Isra and Mi\'raj',
    '8/15': 'Laylat al-Bara\'at',
    '9/1': 'Beginning of Ramadan',
    '9/27': 'Laylat al-Qadr',
    '10/1': 'Eid al-Fitr',
    '12/8': 'Day of Arafah',
    '12/10': 'Eid al-Adha',
  };
  
  // Supported Languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
    'ur': 'اردو',
    'hi': 'हिन्दी',
    'fr': 'Français',
    'tr': 'Türkçe',
    'ms': 'Bahasa Melayu',
    'id': 'Bahasa Indonesia',
  };
  
  // Quranic Recitation Styles
  static const List<String> recitationStyles = [
    'Abdul Rahman Al-Sudais',
    'Mishary Rashid Alafasy',
    'Saad Al Ghamdi',
    'Ahmed Ali Al Ajamy',
    'Hani Ar Rifai',
    'Khalil Al Hussary',
    'Abdul Muhsin Al Qasim',
    'AbdulBaset AbdulSamad',
    'Abdullah Awad Al Juhani',
    'Fares Abbad',
    'Maher Al Mueaqly',
    'Muhammad Ayyub',
    'Muhammad Jibreel',
    'Sahl Yassin',
    'Yasser Al Dosari',
  ];
  
  // Notifications
  static const String prayerNotificationChannelId = 'prayer_notifications';
  static const String reminderNotificationChannelId = 'reminder_notifications';
  static const String athanNotificationChannelId = 'athan_notifications';
  
  // Local Storage Keys
  static const String userLocationKey = 'user_location';
  static const String selectedLanguageKey = 'selected_language';
  static const String selectedMadhabKey = 'selected_madhab';
  static const String selectedMethodKey = 'selected_method';
  static const String notificationPrefsKey = 'notification_preferences';
  static const String prayerTimesKey = 'prayer_times';
  static const String qiblaDirectionKey = 'qibla_direction';
  static const String lastReadQuranKey = 'last_read_quran';
  static const String bookmarksKey = 'bookmarks';
  static const String tasbeehCountKey = 'tasbeeh_count';
  static const String prayerTrackingKey = 'prayer_tracking';
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String themePreferenceKey = 'theme_preference';
  
  // Default Values
  static const double defaultLatitude = 21.3891;
  static const double defaultLongitude = 39.8579; // Mecca coordinates
  static const String defaultCity = 'Mecca';
  static const String defaultCountry = 'Saudi Arabia';
  static const int defaultCalculationMethod = 4; // Umm Al-Qura
  static const String defaultMadhab = 'Hanafi';
  static const String defaultLanguage = 'en';
  
  // Sizes and Dimensions
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;
  
  // Animations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxQuranVerses = 6236;
  
  // Error Messages
  static const String noInternetError = 'No internet connection available';
  static const String locationPermissionError = 'Location permission denied';
  static const String unknownError = 'An unknown error occurred';
  static const String serverError = 'Server error. Please try again later';
}