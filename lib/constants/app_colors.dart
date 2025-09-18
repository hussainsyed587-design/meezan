import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Islamic Green
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color darkGreen = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color gold = Color(0xFFFFB300); // Islamic Gold
  static const Color lightGold = Color(0xFFFFD54F);
  static const Color darkGold = Color(0xFFFF8F00);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGrey = Color(0xFF212121);
  static const Color mediumGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color background = Color(0xFFFAFAFA);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Prayer Time Colors
  static const Color fajrColor = Color(0xFF3F51B5); // Deep Blue for dawn
  static const Color dhuhrColor = Color(0xFFFF9800); // Orange for midday
  static const Color asrColor = Color(0xFFFF5722); // Red-orange for afternoon
  static const Color maghribColor = Color(0xFF9C27B0); // Purple for sunset
  static const Color ishaColor = Color(0xFF673AB7); // Deep purple for night
  
  // Arabic/Islamic Theme Colors
  static const Color arabicAccent = Color(0xFF8BC34A);
  static const Color quranicGold = Color(0xFFD4AF37);
  static const Color mosqueGreen = Color(0xFF006400);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkPrimary = Color(0xFF66BB6A);
  
  // Gradient Colors
  static const List<Color> greenGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];
  
  static const List<Color> goldGradient = [
    Color(0xFFFFB300),
    Color(0xFFFFD54F),
  ];
  
  static const List<Color> prayerTimeGradient = [
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
  ];
  
  static const List<Color> sunsetGradient = [
    Color(0xFFFF7043),
    Color(0xFFFFB74D),
  ];
  
  static const List<Color> nightGradient = [
    Color(0xFF283593),
    Color(0xFF5C6BC0),
  ];
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardBorder = Color(0xFFE0E0E0);
  
  // Button Colors
  static const Color buttonPrimary = primaryGreen;
  static const Color buttonSecondary = gold;
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  
  // Input Colors
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocused = primaryGreen;
  static const Color inputError = error;
  
  // Prayer Status Colors
  static const Color prayerCompleted = success;
  static const Color prayerMissed = error;
  static const Color prayerPending = warning;
  
  // Qibla Colors
  static const Color qiblaArrow = gold;
  static const Color compassBackground = Color(0xFFF5F5F5);
  static const Color compassBorder = primaryGreen;
  
  // Special Islamic Colors
  static const Color kaaba = Color(0xFF2C2C2C);
  static const Color hajjGreen = Color(0xFF228B22);
  static const Color ramadanBlue = Color(0xFF191970);
  
  // Event Type Colors
  static const Color celebrationPurple = Color(0xFF9C27B0);
  static const Color historicalBrown = Color(0xFF8D6E63);
  static const Color communityOrange = Color(0xFFFF9800);
  static const Color personalTeal = Color(0xFF009688);
  
  // Color Scheme Methods
  static ColorScheme lightColorScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    brightness: Brightness.light,
    primary: primaryGreen,
    secondary: gold,
    surface: white,
    background: background,
    error: error,
  );
  
  static ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: darkPrimary,
    brightness: Brightness.dark,
    primary: darkPrimary,
    secondary: lightGold,
    surface: darkSurface,
    background: darkBackground,
    error: error,
  );
}