import 'friday_update.dart';

/// Categories students can filter announcements by.
enum AnnouncementCategory {
  general('General'),
  jumuah("Jumu'ah"),
  events('Events'),
  important('Important');

  const AnnouncementCategory(this.label);

  final String label;
}

/// A masjid announcement shown on S3, previewed on S1 and opened on S3.1.
class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.publishedAt,
    this.imageUrl,
    this.eventTime,
    this.location,
  });

  /// A Friday update from the Jumu'ah screen (S4) shown as an announcement,
  /// so it can be opened on the detail screen (S3.1).
  factory Announcement.fromFridayUpdate(FridayUpdate update) {
    return Announcement(
      id: update.id,
      title: update.title,
      description: update.body,
      category: AnnouncementCategory.jumuah,
      publishedAt: update.date,
    );
  }

  final String id;
  final String title;
  final String description;
  final AnnouncementCategory category;
  final DateTime publishedAt;

  /// Optional image loaded from the network.
  final String? imageUrl;

  /// Optional event details, shown on the detail screen.
  final String? eventTime;
  final String? location;

  bool get hasEventDetails => eventTime != null || location != null;

  Announcement copyWith({
    String? title,
    String? description,
    AnnouncementCategory? category,
    DateTime? publishedAt,
  }) {
    return Announcement(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      imageUrl: imageUrl,
      eventTime: eventTime,
      location: location,
    );
  }
}
