/// The five daily prayers, in order, with their Arabic names.
enum Prayer {
  fajr('Fajr', 'الفجر'),
  dhuhr('Dhuhr', 'الظهر'),
  asr('Asr', 'العصر'),
  maghrib('Maghrib', 'المغرب'),
  isha('Isha', 'العشاء');

  const Prayer(this.label, this.arabicName);

  final String label;
  final String arabicName;
}

/// One prayer on one date: its adhan time and the masjid's iqamah time.
///
/// Times are Türkiye wall-clock times, stored as UTC values whose hour and
/// minute read as Istanbul time. That way comparisons and countdowns never
/// depend on the phone's own time zone (see PrayerService).
class PrayerSchedule {
  const PrayerSchedule({
    required this.date,
    required this.prayer,
    required this.adhanTime,
    required this.iqamahTime,
  });

  /// The calendar day (midnight) this entry belongs to.
  final DateTime date;
  final Prayer prayer;
  final DateTime adhanTime;
  final DateTime iqamahTime;

  String get prayerName => prayer.label;

  PrayerSchedule copyWith({DateTime? adhanTime, DateTime? iqamahTime}) {
    return PrayerSchedule(
      date: date,
      prayer: prayer,
      adhanTime: adhanTime ?? this.adhanTime,
      iqamahTime: iqamahTime ?? this.iqamahTime,
    );
  }
}

/// The masjid's timetable for one day: the five prayers plus optional notes.
class DaySchedule {
  const DaySchedule({required this.date, required this.prayers, this.notes});

  final DateTime date;

  /// Always five entries, Fajr to Isha.
  final List<PrayerSchedule> prayers;

  /// Optional notes from the masjid for this day.
  final String? notes;

  DaySchedule copyWith({List<PrayerSchedule>? prayers, String? notes}) {
    return DaySchedule(
      date: date,
      prayers: prayers ?? this.prayers,
      notes: notes ?? this.notes,
    );
  }
}
