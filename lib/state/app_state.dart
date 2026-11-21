import 'package:flutter/foundation.dart';

import '../data/sample_announcements.dart';
import '../data/sample_timetable.dart';
import '../models/announcement.dart';
import '../models/prayer_schedule.dart';
import '../services/prayer_service.dart';

/// The timetable and announcements, shared by every screen.
///
/// There is one shared instance, [AppState.instance]. Screens rebuild when it
/// changes by wrapping their content in a `ListenableBuilder`. Because the
/// admin screens change the same object, their edits appear on the student
/// screens straight away. Nothing is saved yet: Firebase arrives in Step 3.
class AppState extends ChangeNotifier {
  AppState({DateTime? today}) {
    _load(today ?? PrayerService.todayInTurkey());
  }

  static final AppState instance = AppState();

  void _load(DateTime today) {
    _timetable.clear();
    for (final day in SampleTimetable.generate(today: PrayerService.dateOnly(today))) {
      _timetable[day.date] = day;
    }
    _announcements
      ..clear()
      ..addAll(SampleAnnouncements.all());
    _hiddenIds.clear();
    _filter = null;
  }

  /// Puts the sample data back (used by the tests).
  @visibleForTesting
  void reset({DateTime? today}) {
    _load(today ?? PrayerService.todayInTurkey());
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Prayer timetable (S1, S2; edited on S9)

  final Map<DateTime, DaySchedule> _timetable = {};

  /// The timetable for [date], or null if none has been published.
  DaySchedule? dayFor(DateTime date) => _timetable[PrayerService.dateOnly(date)];

  /// Every published day, earliest first.
  List<DaySchedule> get scheduledDays =>
      _timetable.values.toList()..sort((a, b) => a.date.compareTo(b.date));

  /// Adds or replaces one day's times (S9). When an admin moves a day to a
  /// new date, pass the old date as [replacing] so it is removed.
  void saveDay(DaySchedule day, {DateTime? replacing}) {
    if (replacing != null) _timetable.remove(PrayerService.dateOnly(replacing));
    _timetable[PrayerService.dateOnly(day.date)] = day;
    notifyListeners();
  }

  /// Same as [saveDay] without moving the date.
  void updateDay(DaySchedule day) => saveDay(day);

  /// Removes one day's timetable (S7, after confirmation).
  void deleteDay(DateTime date) {
    if (_timetable.remove(PrayerService.dateOnly(date)) != null) notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Announcements (S1, S3, S3.1; managed on S7 and S8)

  final List<Announcement> _announcements = [];
  final Set<String> _hiddenIds = {};
  AnnouncementCategory? _filter;

  /// Every announcement, newest first (for the admin dashboard).
  List<Announcement> get allAnnouncements =>
      List.of(_announcements)..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  /// Announcements the student has not hidden, newest first.
  List<Announcement> get visibleAnnouncements =>
      allAnnouncements.where((a) => !_hiddenIds.contains(a.id)).toList();

  /// The category selected on S3, or null for all.
  AnnouncementCategory? get filter => _filter;

  /// Visible announcements in the selected category.
  List<Announcement> get filteredAnnouncements {
    final filter = _filter;
    if (filter == null) return visibleAnnouncements;
    return visibleAnnouncements.where((a) => a.category == filter).toList();
  }

  bool get hasHiddenAnnouncements => _hiddenIds.isNotEmpty;

  Announcement? announcementById(String id) {
    for (final announcement in _announcements) {
      if (announcement.id == id) return announcement;
    }
    return null;
  }

  bool isHidden(String id) => _hiddenIds.contains(id);

  void setFilter(AnnouncementCategory? category) {
    if (_filter == category) return;
    _filter = category;
    notifyListeners();
  }

  /// Hides an announcement on this device only. The official announcement is
  /// not deleted; only admins can do that (S7).
  void hideAnnouncement(String id) {
    if (_hiddenIds.add(id)) notifyListeners();
  }

  void unhideAnnouncement(String id) {
    if (_hiddenIds.remove(id)) notifyListeners();
  }

  /// Clears the filter and brings back hidden announcements.
  void showAllAnnouncements() {
    _hiddenIds.clear();
    _filter = null;
    notifyListeners();
  }

  /// Publishes a new announcement from the S8 form. It appears on S1 and S3
  /// straight away.
  void addAnnouncement(Announcement announcement) {
    _announcements.add(announcement);
    notifyListeners();
  }

  /// Saves an edited announcement (for the S8 form in edit mode).
  void updateAnnouncement(Announcement updated) {
    final index = _announcements.indexWhere((a) => a.id == updated.id);
    if (index == -1) return;
    _announcements[index] = updated;
    notifyListeners();
  }

  /// Deletes an announcement for everyone (for S7, after confirmation).
  void deleteAnnouncement(String id) {
    _announcements.removeWhere((a) => a.id == id);
    _hiddenIds.remove(id);
    notifyListeners();
  }
}
