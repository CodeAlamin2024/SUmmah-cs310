/// Form validators shared across the sign-in, create-account, announcement,
/// and timetable forms.
///
/// Each validator returns `null` when the value is valid, or the inline
/// error message shown under the field (texts match the Figma frames).
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static const int minPasswordLength = 8;
  static const int maxAnnouncementTitleLength = 80;
  static const int minAnnouncementDescriptionLength = 20;
  static const int maxTimetableNotesLength = 140;

  static String? fullName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Enter your full name';
    }
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty || !_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Sign-in: password only has to be filled in.
  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    }
    return null;
  }

  /// Create account: password needs a minimum length.
  static String? newPassword(String? value) {
    if (value == null || value.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters';
    }
    return null;
  }

  /// Returns a validator that compares the value with [originalPassword].
  static String? Function(String?) confirmPassword(
    String Function() originalPassword,
  ) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Confirm your password';
      }
      if (value != originalPassword()) {
        return "Passwords don't match";
      }
      return null;
    };
  }

  /// S8 – Announcement title: required, up to 80 characters.
  static String? announcementTitle(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Enter a title';
    }
    if (text.length > maxAnnouncementTitleLength) {
      return 'Use at most $maxAnnouncementTitleLength characters';
    }
    return null;
  }

  /// S8 – Announcement description: required, at least 20 characters.
  static String? announcementDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < minAnnouncementDescriptionLength) {
      return 'Write at least $minAnnouncementDescriptionLength characters';
    }
    return null;
  }

  /// S8 – Announcement category: required selection.
  static String? announcementCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Choose a category';
    }
    return null;
  }

  /// S9 – Timetable day notes: optional, up to 140 characters.
  static String? timetableNotes(String? value) {
    if (value != null && value.trim().length > maxTimetableNotesLength) {
      return 'Use at most $maxTimetableNotesLength characters';
    }
    return null;
  }
}
