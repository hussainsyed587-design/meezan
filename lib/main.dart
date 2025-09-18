import 'package:flutter/material.dart';
import 'package:meezan_app/providers/prayer_statistics_provider.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'constants/app_constants.dart';
import 'screens/splash_screen.dart';
import 'providers/prayer_times_provider.dart';
import 'providers/location_provider.dart';
import 'providers/user_preferences_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/duas_provider.dart';
import 'services/config_service.dart';
// import 'services/notification_service.dart'; // Temporarily disabled

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize configuration
  ConfigService.initialize();
  
  // Initialize notification service - temporarily disabled
  // await NotificationService().initialize();
  
  runApp(const MeezanApp());
}

class MeezanApp extends StatelessWidget {
  const MeezanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PrayerTimesProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => DuasProvider()),
        ChangeNotifierProvider(create: (_) => PrayerStatisticsProvider()),
      ],
      child: Consumer<UserPreferencesProvider>(
        builder: (context, preferencesProvider, child) {
          return MaterialApp(
            title: AppConstants.appFullName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: preferencesProvider.preferences.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
