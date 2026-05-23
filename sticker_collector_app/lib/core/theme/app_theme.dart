import 'package:flutter/material.dart';

/// Application theme configuration
class AppTheme {
  AppTheme._();

  // Primary colors (FIFA style blue)
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Status colors
  static const Color ownedColor = Color(0xFF4CAF50);
  static const Color ownedBackgroundColor = Color(0xFFE8F5E9);
  static const Color missingColor = Color(0xFF9E9E9E);
  static const Color missingBackgroundColor = Color(0xFFF5F5F5);
  static const Color repeatedColor = Color(0xFFFFB300);
  static const Color repeatedBackgroundColor = Color(0xFFFFF8E1);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Colors.white;

  // Card colors
  static const Color cardColor = Colors.white;
  static const Color cardBorderColor = Color(0xFFE0E0E0);

  /// Get the main Material theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: textOnPrimary,
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        color: cardColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
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
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
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
    if (percent >= 90) return Colors.green;
    if (percent >= 50) return primaryColor;
    return Colors.orange;
  }
}