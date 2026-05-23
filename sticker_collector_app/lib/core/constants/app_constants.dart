/// Application-wide constants
class AppConstants {
  AppConstants._();

  /// Hardcoded user ID for Phase 1 (single user, no auth)
  static const String defaultUserId = 'default_user';

  /// Application name
  static const String appName = 'CromoManía 2026';

  /// Database file name
  static const String databaseName = 'cromomania_2026.db';

  /// Maximum sticker count per sticker (for safety)
  static const int maxStickerCount = 999;

  /// Default cross-axis count for sticker grid
  static const int defaultGridColumns = 4;

  /// Sticker tile aspect ratio (width / height)
  static const double stickerTileAspectRatio = 0.85;
}