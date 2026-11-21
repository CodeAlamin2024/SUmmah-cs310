import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:summah/models/announcement.dart';
import 'package:summah/models/prayer_schedule.dart';
import 'package:summah/screens/admin_dashboard_screen.dart';
import 'package:summah/screens/announcement_form_screen.dart';
import 'package:summah/screens/timetable_form_screen.dart';
import 'package:summah/services/prayer_service.dart';
import 'package:summah/state/app_state.dart';
import 'package:summah/utils/app_theme.dart';
import 'package:summah/utils/date_format.dart';

Widget _wrap(Widget screen) => MaterialApp(
      theme: AppTheme.light,
      home: screen,
    );

/// A fixed Monday so the form tests always show the same dates.
final DateTime _monday = DateTime.utc(2026, 11, 16);

DaySchedule _sampleDay() => AppState(today: _monday).dayFor(_monday)!;

void main() {
  // Every test starts from the same sample data.
  setUp(() => AppState.instance.reset());

  testWidgets('S7 shows summary counts, announcements and the timetable',
      (tester) async {
    final state = AppState.instance;
    await tester.pumpWidget(_wrap(const AdminDashboardScreen()));

    expect(find.text('Admin dashboard'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('${state.allAnnouncements.length}'), findsOneWidget);
    expect(find.text('${state.scheduledDays.length}'), findsOneWidget);
    expect(find.text(state.allAnnouncements.first.title), findsOneWidget);
    expect(find.text('New announcement'), findsOneWidget);

    await tester.tap(find.text('Timetable'));
    await tester.pumpAndSettle();

    final today = PrayerService.todayInTurkey();
    final days = state.scheduledDays;
    expect(find.text(DateFormatter.weekdayShort(today)), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Add day'), findsOneWidget);
    expect(
      find.text('Timetable published for '
          '${DateFormatter.range(days.first.date, days.last.date)}'),
      findsOneWidget,
    );
  });

  testWidgets('S7 deletes an announcement for everyone after D3', (tester) async {
    final state = AppState.instance;
    final first = state.allAnnouncements.first;
    final countBefore = state.allAnnouncements.length;
    await tester.pumpWidget(_wrap(const AdminDashboardScreen()));

    await tester.tap(find.byTooltip('Delete announcement').first);
    await tester.pumpAndSettle();
    expect(find.text('Delete announcement?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text(first.title), findsNothing);
    expect(find.text('${countBefore - 1}'), findsOneWidget);
    expect(find.text('Announcement deleted'), findsOneWidget);
    // Also gone from the students' feed (S1, S3).
    expect(state.announcementById(first.id), isNull);
  });

  testWidgets('S7 adds and deletes a timetable day', (tester) async {
    final state = AppState.instance;
    final countBefore = state.scheduledDays.length;
    final firstDay = state.scheduledDays.first.date;
    final newDay = state.scheduledDays.last.date.add(const Duration(days: 1));
    await tester.pumpWidget(_wrap(const AdminDashboardScreen()));

    await tester.tap(find.text('Timetable'));
    await tester.pumpAndSettle();

    // "Add day" opens S9 on the first date without a timetable.
    await tester.tap(find.text('Add day'));
    await tester.pumpAndSettle();
    expect(find.text('Add timetable'), findsWidgets);

    final addButton = find.widgetWithText(FilledButton, 'Add timetable');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text('Save timetable for ${DateFormatter.short(newDay)}?'),
        findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();

    expect(find.text('${countBefore + 1}'), findsOneWidget);
    expect(find.text('Timetable added'), findsOneWidget);
    expect(state.dayFor(newDay), isNotNull);

    // Delete the first day.
    final deleteFirst =
        find.byTooltip('Delete timetable for ${DateFormatter.short(firstDay)}');
    await tester.ensureVisible(deleteFirst);
    await tester.tap(deleteFirst);
    await tester.pumpAndSettle();
    expect(find.text('Delete timetable?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('$countBefore'), findsOneWidget);
    expect(find.text('Timetable deleted'), findsOneWidget);
    expect(state.dayFor(firstDay), isNull);
  });

  testWidgets('S8 shows inline validation errors when submitted empty',
      (tester) async {
    await tester.pumpWidget(_wrap(const AnnouncementFormScreen()));

    final publishButton = find.widgetWithText(FilledButton, 'Publish');
    await tester.ensureVisible(publishButton);
    await tester.tap(publishButton);
    await tester.pump();

    expect(find.text('Enter a title'), findsOneWidget);
    expect(find.text('Write at least 20 characters'), findsOneWidget);
    // The dropdown hint and its error message.
    expect(find.text('Choose a category'), findsNWidgets(2));
  });

  testWidgets('S8 publishes from S7 and the announcement reaches the feed',
      (tester) async {
    await tester.pumpWidget(_wrap(const AdminDashboardScreen()));

    await tester.tap(find.text('New announcement'));
    await tester.pumpAndSettle();

    const title = 'Ramadan preparation meeting';
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), title);
    await tester.enterText(
      fields.at(1),
      'Join us after Maghrib to coordinate volunteers for the upcoming month.',
    );

    await tester.tap(find.byType(DropdownButtonFormField<AnnouncementCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Events').last);
    await tester.pumpAndSettle();

    final publishButton = find.widgetWithText(FilledButton, 'Publish');
    await tester.ensureVisible(publishButton);
    await tester.tap(publishButton);
    await tester.pumpAndSettle();

    // D2 confirmation dialog.
    expect(find.text('Publish announcement?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Publish'));
    await tester.pumpAndSettle();

    expect(find.text('Announcement published'), findsOneWidget);
    final newest = AppState.instance.allAnnouncements.first;
    expect(newest.title, title);
    expect(newest.category, AnnouncementCategory.events);
  });

  testWidgets('S9 shows an inline error when iqamah is before adhan',
      (tester) async {
    final day = _sampleDay();
    final prayers = List<PrayerSchedule>.from(day.prayers);
    prayers[2] = prayers[2].copyWith(
      adhanTime: DateTime.utc(2026, 11, 16, 15, 26),
      iqamahTime: DateTime.utc(2026, 11, 16, 15, 20),
    );

    await tester.pumpWidget(
      _wrap(TimetableFormScreen(schedule: day.copyWith(prayers: prayers))),
    );

    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Iqamah must be after adhan (15:26)'), findsOneWidget);
  });

  testWidgets('S9 shows an inline error for a duplicate date', (tester) async {
    final day = _sampleDay();

    await tester.pumpWidget(_wrap(TimetableFormScreen(
      schedule: day,
      existingDates: [day.date],
    )));

    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('A timetable for 16 Nov already exists'), findsOneWidget);

    // The date field opens the date picker.
    await tester.tap(find.byKey(const Key('timetable_date_picker')));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('S9 shows the D4 dialog when all times are valid', (tester) async {
    await tester.pumpWidget(_wrap(TimetableFormScreen(schedule: _sampleDay())));

    final saveButton = find.widgetWithText(FilledButton, 'Save changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Save timetable for 16 Nov?'), findsOneWidget);
  });
}
