import 'package:flutter/material.dart';

import 'models/announcement.dart';
import 'models/prayer_schedule.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_sign_in_screen.dart';
import 'screens/announcement_detail_screen.dart';
import 'screens/announcement_form_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/main_shell.dart';
import 'screens/timetable_form_screen.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const SummahApp());
}

class SummahApp extends StatelessWidget {
  const SummahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUmmah',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.shell,
      routes: {
        AppRoutes.shell: (_) => const MainShell(), // S1–S4 tabs
        AppRoutes.announcementDetail: (_) => const AnnouncementDetailScreen(), // S3.1
        AppRoutes.adminSignIn: (_) => const AdminSignInScreen(), // S5
        AppRoutes.createAccount: (_) => const CreateAccountScreen(), // S6
        AppRoutes.adminDashboard: (_) => const AdminDashboardScreen(), // S7
      },
      // S8 and S9 take an optional item to edit, so they are built here.
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.announcementForm) {
          final existing = settings.arguments as Announcement?;
          return MaterialPageRoute<Announcement>(
            settings: settings,
            builder: (_) => AnnouncementFormScreen(initialAnnouncement: existing),
          );
        }
        if (settings.name == AppRoutes.timetableForm) {
          final existing = settings.arguments as DaySchedule?;
          return MaterialPageRoute<DaySchedule>(
            settings: settings,
            builder: (_) => TimetableFormScreen(schedule: existing),
          );
        }
        return null;
      },
    );
  }
}
