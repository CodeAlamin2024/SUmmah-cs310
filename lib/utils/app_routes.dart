/// Named routes used across the app. Keep every route name here so
/// screens never hard-code strings.
class AppRoutes {
  AppRoutes._();

  /// Bottom-navigation shell (Home, Timetable, Announcements, Jumu'ah).
  static const String shell = '/';

  /// Announcement detail (S3.1). Pass the Announcement as `arguments`.
  static const String announcementDetail = '/announcement';

  static const String adminSignIn = '/admin/sign-in'; // S5
  static const String createAccount = '/admin/create-account'; // S6
  static const String announcementForm = '/admin/announcement-form'; // S8
  static const String timetableForm = '/admin/timetable-form'; // S9
  static const String adminDashboard = '/admin/dashboard'; // S7
}
