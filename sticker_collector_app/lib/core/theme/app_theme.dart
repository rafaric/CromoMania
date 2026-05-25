import 'package:flutter/material.dart';

/// Application theme configuration.
class AppTheme {
  AppTheme._();

  // Panini-inspired palette.
  static const Color primaryColor = Color(0xFFD71920);
  static const Color primaryDark = Color(0xFFA50F15);
  static const Color primaryLight = Color(0xFFFFE082);
  static const Color accentBlue = Color(0xFF0057B8);
  static const Color surfaceTint = Color(0xFFFFF8E7);

  // Status colors
  static const Color ownedColor = Color(0xFF2E7D32);
  static const Color ownedBackgroundColor = Color(0xFFE8F5E9);
  static const Color missingColor = Color(0xFF90A4AE);
  static const Color missingBackgroundColor = Color(0xFFF5F7FA);
  static const Color repeatedColor = Color(0xFFFFB300);
  static const Color repeatedBackgroundColor = Color(0xFFFFF4CC);

  // Text colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color textOnPrimary = Colors.white;

  // Card colors
  static const Color cardColor = Colors.white;
  static const Color cardBorderColor = Color(0xFFFFD54F);

  /// Get the main Material theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: primaryColor,
            brightness: Brightness.light,
          ).copyWith(
            primary: primaryColor,
            secondary: accentBlue,
            surface: Colors.white,
          ),
      scaffoldBackgroundColor: surfaceTint,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
      ),
      cardTheme: const CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: cardBorderColor),
        ),
        color: cardColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
      ),
    );
  }

  /// Get background color based on sticker status
  static Color getStatusBackgroundColor(int count) {
    if (count == 0) return missingBackgroundColor;
    if (count == 1) return ownedBackgroundColor;
    return repeatedBackgroundColor;
  }

  /// Get border color based on sticker status
  static Color getStatusBorderColor(int count) {
    if (count == 0) return missingColor;
    if (count == 1) return ownedColor;
    return repeatedColor;
  }

  /// Get progress ring color based on percentage
  static Color getProgressColor(double percent) {
    if (percent >= 90) return ownedColor;
    if (percent >= 50) return accentBlue;
    return repeatedColor;
  }
}
