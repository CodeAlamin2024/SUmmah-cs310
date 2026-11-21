import 'package:flutter/material.dart';

/// Small date and time helpers so we don't need the `intl` package for Step 2.
class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// 20 November 2026
  static String long(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year}';

  /// 13 Nov
  static String short(DateTime date) =>
      '${date.day} ${_months[date.month - 1].substring(0, 3)}';

  static const List<String> _weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
    'Sunday',
  ];

  /// Thursday, 19 November 2026
  static String full(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${long(date)}';

  /// Thu, 19 Nov 2026
  static String shortWithWeekday(DateTime date) =>
      '${_weekdays[date.weekday - 1].substring(0, 3)}, ${short(date)} ${date.year}';

  /// 19 November
  static String dayMonth(DateTime date) =>
      '${date.day} ${_months[date.month - 1]}';

  /// 15:26
  static String time(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

  /// 01:13:48 (used by the live countdown)
  static String countdown(Duration duration) {
    final seconds = duration.isNegative ? 0 : duration.inSeconds;
    return '${_two(seconds ~/ 3600)}:${_two(seconds % 3600 ~/ 60)}:${_two(seconds % 60)}';
  }

  /// 1 h 13 min, 13 min, or "less than a minute"
  static String relative(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 1) return 'less than a minute';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    if (hours == 0) return '$rest min';
    if (rest == 0) return '$hours h';
    return '$hours h $rest min';
  }

  // --- Admin screens (S7–S9) -------------------------------------------------

  /// 16 Nov 2026
  static String medium(DateTime date) =>
      '${date.day} ${_months[date.month - 1].substring(0, 3)} ${date.year}';

  /// Mon 16 Nov
  static String weekdayShort(DateTime date) =>
      '${_weekdays[date.weekday - 1].substring(0, 3)} ${short(date)}';

  /// Monday, 16 November 2026
  static String weekdayLong(DateTime date) =>
      '${_weekdays[date.weekday - 1]}, ${long(date)}';

  /// "16 to 29 November" (same month) or "16 Nov to 2 Dec" (different months).
  static String range(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.day} to ${end.day} ${_months[start.month - 1]}';
    }
    return '${short(start)} to ${short(end)}';
  }

  /// True when [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Formats a 24-hour time as `HH:mm` (e.g. `06:45`).
  static String time24(TimeOfDay time) => '${_two(time.hour)}:${_two(time.minute)}';

  /// Total minutes since midnight, used for comparing [TimeOfDay] values.
  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static String _two(int n) => n.toString().padLeft(2, '0');
}
