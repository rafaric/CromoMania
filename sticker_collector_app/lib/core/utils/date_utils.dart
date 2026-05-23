import 'package:intl/intl.dart';

/// Date formatting utilities
class DateUtils {
  DateUtils._();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat _displayFormat = DateFormat('MMM d, yyyy');

  /// Format date for display (e.g., "May 22, 2026")
  static String formatForDisplay(DateTime date) {
    return _displayFormat.format(date);
  }

  /// Format date for storage/logs (e.g., "2026-05-22")
  static String formatForStorage(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Format datetime for storage/logs (e.g., "2026-05-22 14:30")
  static String formatDateTimeForStorage(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  /// Parse date from storage format
  static DateTime? parseFromStorage(String? dateString) {
    if (dateString == null) return null;
    try {
      return _dateFormat.parse(dateString);
    } catch (_) {
      try {
        return _dateTimeFormat.parse(dateString);
      } catch (_) {
        return null;
      }
    }
  }
}