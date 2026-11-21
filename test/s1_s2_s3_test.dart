import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summah/main.dart';
import 'package:summah/models/announcement.dart';
import 'package:summah/models/prayer_schedule.dart';
import 'package:summah/screens/announcements_screen.dart';
import 'package:summah/screens/timetable_screen.dart';
import 'package:summah/services/prayer_service.dart';
import 'package:summah/state/app_state.dart';
import 'package:summah/utils/app_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

Finder _navTab(String label) => find.widgetWithText(NavigationDestination, label);

void main() {
  // Every test starts from the same sample data.
  setUp(() => AppState.instance.reset());

  group('PrayerService', () {
    final day = DateTime.utc(2026, 11, 19); // a Thursday
    final state = AppState(today: day);

    test('finds the next prayer during the day', () {
      final now = DateTime.utc(2026, 11, 19, 12, 0);
      final status = PrayerService.status(state.dayFor, now)!;
      expect(status.next.prayer, Prayer.dhuhr);
      expect(status.next.type, PrayerEventType.adhan);
      expect(status.isTomorrow, isFalse);
      expect(status.progress, inInclusiveRange(0, 1));
    });

    test('moves on to tomorrow\'s Fajr after Isha', () {
      final now = DateTime.utc(2026, 11, 19, 23, 0);
      final status = PrayerService.status(state.dayFor, now)!;
      expect(status.next.prayer, Prayer.fajr);
      expect(status.isTomorrow, isTrue);
      expect(PrayerService.highlightedPrayer(status, now), isNull);
    });

    test('Friday Dhuhr iqamah matches the Jumu\'ah salah time', () {
      final friday = state.dayFor(DateTime.utc(2026, 11, 20))!;
      final dhuhr = friday.prayers.firstWhere((p) => p.prayer == Prayer.dhuhr);
      expect(dhuhr.iqamahTime.hour, 13);
      expect(dhuhr.iqamahTime.minute, 20);
      expect(friday.notes, contains("Jumu'ah"));
    });
  });

  testWidgets('S1 shows the countdown, today\'s prayers and opens S2',
      (tester) async {
    await tester.pumpWidget(const SummahApp());

    expect(find.textContaining('Next prayer'), findsOneWidget);
    expect(find.text("Today's prayers"), findsOneWidget);
    for (final prayer in Prayer.values) {
      expect(find.text(prayer.label), findsWidgets);
    }

    await tester.ensureVisible(find.text('Full timetable'));
    await tester.tap(find.text('Full timetable'));
    await tester.pump();
    expect(find.text('Prayer timetable'), findsOneWidget);
  });

  testWidgets('S2 moves between days and shows an empty state when no times exist',
      (tester) async {
    await tester.pumpWidget(_wrap(const TimetableScreen()));
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.byTooltip('Next day'));
    await tester.pump();
    expect(find.text('Not today'), findsOneWidget);
    expect(find.text('Back to today'), findsOneWidget);

    // Sample times are published 13 days ahead; the 14th day has none.
    for (var i = 0; i < 13; i++) {
      await tester.tap(find.byTooltip('Next day'));
      await tester.pump();
    }
    expect(find.text('No timetable for this date'), findsOneWidget);

    await tester.ensureVisible(find.text('Back to today'));
    await tester.tap(find.text('Back to today'));
    await tester.pump();
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('S3 filters announcements by category', (tester) async {
    await tester.pumpWidget(_wrap(const AnnouncementsScreen()));

    await tester.tap(find.widgetWithText(ChoiceChip, 'Events'));
    await tester.pump();

    expect(AppState.instance.filter, AnnouncementCategory.events);
    expect(find.text('Thursday halaqa after Maghrib'), findsOneWidget);
    expect(find.text('Volunteers needed for masjid cleaning'), findsNothing);
  });

  testWidgets('S3 hides an announcement and Undo brings it back', (tester) async {
    await tester.pumpWidget(_wrap(const AnnouncementsScreen()));
    final title = AppState.instance.filteredAnnouncements.first.title;
    expect(find.text(title), findsOneWidget);

    await tester.tap(find.byTooltip('Hide announcement').first);
    await tester.pumpAndSettle();
    expect(find.text(title), findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('S3.1 opens from S3 with the event details', (tester) async {
    await tester.pumpWidget(const SummahApp());
    await tester.tap(_navTab('Announcements'));
    await tester.pump();

    const title = 'Thursday halaqa after Maghrib';
    await tester.ensureVisible(find.text(title));
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();

    expect(find.text('Announcement'), findsOneWidget);
    expect(find.text('Thursdays after Maghrib'), findsOneWidget);
    expect(find.text('Masjid study room'), findsOneWidget);
  });

  testWidgets('S4 "All Friday updates" opens S3 filtered to Jumu\'ah',
      (tester) async {
    await tester.pumpWidget(const SummahApp());
    await tester.tap(_navTab("Jumu'ah"));
    await tester.pump();

    await tester.ensureVisible(find.text('All Friday updates'));
    await tester.tap(find.text('All Friday updates'));
    await tester.pump();

    expect(AppState.instance.filter, AnnouncementCategory.jumuah);
    expect(find.text("Arrive early for Jumu'ah"), findsOneWidget);
    expect(find.text('Thursday halaqa after Maghrib'), findsNothing);
  });
}
