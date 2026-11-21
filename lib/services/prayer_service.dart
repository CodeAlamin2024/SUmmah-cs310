import '../models/prayer_schedule.dart';

/// Whether an event is the call to prayer or the start of the congregation.
enum PrayerEventType {
  adhan('adhan'),
  iqamah('iqamah');

  const PrayerEventType(this.label);

  final String label;
}

/// A single adhan or iqamah at a specific time.
class PrayerEvent {
  const PrayerEvent({required this.schedule, required this.type});

  final PrayerSchedule schedule;
  final PrayerEventType type;

  Prayer get prayer => schedule.prayer;

  DateTime get time =>
      type == PrayerEventType.adhan ? schedule.adhanTime : schedule.iqamahTime;

  /// For example "Asr adhan".
  String get label => '${prayer.label} ${type.label}';
}

/// What the countdown card shows: the next event and how far along we are.
class NextPrayerStatus {
  const NextPrayerStatus({required this.next, required this.previous, required this.now});

  final PrayerEvent next;
  final PrayerEvent? previous;
  final DateTime now;

  Duration get remaining => next.time.difference(now);

  /// True when the next event is on a later day (after Isha).
  bool get isTomorrow => next.schedule.date.isAfter(PrayerService.dateOnly(now));

  /// Share of the time between the previous and the next event that has passed.
  double get progress {
    final previousTime = previous?.time;
    if (previousTime == null) return 0;
    final total = next.time.difference(previousTime).inSeconds;
    if (total <= 0) return 0;
    final elapsed = now.difference(previousTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0).toDouble();
  }
}

/// Prayer-time calculations, always in Türkiye time.
///
/// Türkiye has used UTC+3 all year since 2016, so the time at the masjid is
/// the current UTC time plus three hours, whatever time zone the phone is set
/// to. Masjid times are stored as UTC values that read as Istanbul time, so
/// the two can be compared directly.
class PrayerService {
  PrayerService._();

  static const Duration turkeyOffset = Duration(hours: 3);

  /// The current Istanbul wall-clock time, in whole seconds.
  static DateTime nowInTurkey([DateTime? clock]) {
    final t = (clock ?? DateTime.now()).toUtc().add(turkeyOffset);
    return DateTime.utc(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }

  /// Today's date in Istanbul.
  static DateTime todayInTurkey() => dateOnly(nowInTurkey());

  /// Midnight of [date]'s calendar day, as a UTC value.
  static DateTime dateOnly(DateTime date) => DateTime.utc(date.year, date.month, date.day);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Every adhan and iqamah of [day], in time order.
  static List<PrayerEvent> eventsFor(DaySchedule day) {
    final events = <PrayerEvent>[
      for (final entry in day.prayers) ...[
        PrayerEvent(schedule: entry, type: PrayerEventType.adhan),
        PrayerEvent(schedule: entry, type: PrayerEventType.iqamah),
      ],
    ];
    events.sort((a, b) => a.time.compareTo(b.time));
    return events;
  }

  /// The next adhan or iqamah after [now]. Looks from yesterday to two days
  /// ahead, so after Isha it moves on to tomorrow's Fajr.
  ///
  /// Returns null when no upcoming times are published.
  static NextPrayerStatus? status(
    DaySchedule? Function(DateTime date) dayFor,
    DateTime now,
  ) {
    final today = dateOnly(now);
    final events = <PrayerEvent>[];
    for (var offset = -1; offset <= 2; offset++) {
      final day = dayFor(today.add(Duration(days: offset)));
      if (day != null) events.addAll(eventsFor(day));
    }
    events.sort((a, b) => a.time.compareTo(b.time));

    for (var i = 0; i < events.length; i++) {
      if (events[i].time.isAfter(now)) {
        return NextPrayerStatus(
          next: events[i],
          previous: i > 0 ? events[i - 1] : null,
          now: now,
        );
      }
    }
    return null;
  }

  /// The prayer to highlight in today's list, or null once all of today's
  /// prayers have finished.
  static Prayer? highlightedPrayer(NextPrayerStatus? status, DateTime now) {
    if (status == null || !isSameDay(status.next.schedule.date, now)) return null;
    return status.next.prayer;
  }
}
