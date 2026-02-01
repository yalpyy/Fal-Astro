import 'package:intl/intl.dart';

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Format as date string
  String toDateString([String locale = 'tr_TR']) {
    return DateFormat.yMMMd(locale).format(this);
  }

  /// Format as time string
  String toTimeString([String locale = 'tr_TR']) {
    return DateFormat.Hm(locale).format(this);
  }

  /// Format as full date time string
  String toFullString([String locale = 'tr_TR']) {
    return DateFormat.yMMMd(locale).add_Hm().format(this);
  }

  /// Format as relative time (e.g., "2 hours ago")
  String toRelativeString([String locale = 'tr']) {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 30) {
      return toDateString(locale == 'tr' ? 'tr_TR' : 'en_US');
    } else if (difference.inDays > 0) {
      return locale == 'tr'
          ? '${difference.inDays} gün önce'
          : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return locale == 'tr'
          ? '${difference.inHours} saat önce'
          : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return locale == 'tr'
          ? '${difference.inMinutes} dakika önce'
          : '${difference.inMinutes} minutes ago';
    } else {
      return locale == 'tr' ? 'Az önce' : 'Just now';
    }
  }

  /// Check if same day
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Check if today
  bool get isToday => isSameDay(DateTime.now());

  /// Get zodiac sign
  String get zodiacSign {
    final month = this.month;
    final day = this.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'aquarius';
    return 'pisces';
  }
}
