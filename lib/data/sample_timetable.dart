import '../models/prayer_schedule.dart';

/// Sample prayer timetable for Step 2. Replaced by Firebase in Step 3.
///
/// The days are generated around "today", so the app always has a current
/// timetable and a working countdown whenever it is run. The times are
/// illustrative, not the official masjid schedule.
class SampleTimetable {
  SampleTimetable._();

  /// Adhan time on "today" (minutes after midnight), how much it moves per
  /// day, and how long after the adhan the iqamah starts.
  static const List<_Template> _templates = [
    _Template(Prayer.fajr, 6 * 60 + 23, 1.0, 20),
    _Template(Prayer.dhuhr, 12 * 60 + 50, 0.1, 12),
    _Template(Prayer.asr, 15 * 60 + 26, -0.4, 10),
    _Template(Prayer.maghrib, 17 * 60 + 44, -0.6, 5),
    _Template(Prayer.isha, 19 * 60 + 10, -0.5, 20),
  ];

  /// Days from [daysBefore] days ago to [daysAfter] days ahead of [today].
  /// Dates outside this range show the "No timetable" empty state on S2.
  static List<DaySchedule> generate({
    required DateTime today,
    int daysBefore = 3,
    int daysAfter = 13,
  }) {
    return [
      for (var offset = -daysBefore; offset <= daysAfter; offset++)
        _day(today.add(Duration(days: offset)), offset),
    ];
  }

  static DaySchedule _day(DateTime date, int offset) {
    final isFriday = date.weekday == DateTime.friday;
    return DaySchedule(
      date: date,
      prayers: [for (final t in _templates) _entry(date, t, offset)],
      notes: isFriday
          ? "Jumu'ah replaces Dhuhr today. Khutbah 13:00, salah 13:20."
          : null,
    );
  }

  static PrayerSchedule _entry(DateTime date, _Template t, int offset) {
    final adhan = t.adhanMinutes + (t.dailyChange * offset).round();
    // On Fridays the Dhuhr iqamah is the Jumu'ah salah (13:20, as on S4).
    final isJumuah = t.prayer == Prayer.dhuhr && date.weekday == DateTime.friday;
    final iqamah = isJumuah ? 13 * 60 + 20 : _roundUpToFive(adhan + t.iqamahGap);
    return PrayerSchedule(
      date: date,
      prayer: t.prayer,
      adhanTime: _at(date, adhan),
      iqamahTime: _at(date, iqamah),
    );
  }

  static DateTime _at(DateTime date, int minutes) =>
      DateTime.utc(date.year, date.month, date.day, minutes ~/ 60, minutes % 60);

  static int _roundUpToFive(int minutes) => (minutes + 4) ~/ 5 * 5;
}

class _Template {
  const _Template(this.prayer, this.adhanMinutes, this.dailyChange, this.iqamahGap);

  final Prayer prayer;
  final int adhanMinutes;
  final double dailyChange;
  final int iqamahGap;
}
