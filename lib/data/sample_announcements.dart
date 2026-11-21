import '../models/announcement.dart';
import 'sample_data.dart';

/// Sample announcements for Step 2. Replaced by Firebase in Step 3.
class SampleAnnouncements {
  SampleAnnouncements._();

  /// The two images are served from the docs/images folder of our public
  /// GitHub repository, so they load over the network.
  static const String _imageBase =
      'https://raw.githubusercontent.com/CodeAlamin2024/SUmmah-cs310/main/docs/images';

  /// Returns a fresh list every call so changes never touch the originals.
  static List<Announcement> all() => [
        Announcement(
          id: 'an-1',
          title: 'Fajr iqamah is now about 20 minutes after adhan',
          description:
              'With sunrise getting later, Fajr iqamah has moved to about 20 minutes '
              'after the adhan. Check the timetable for the exact time each day.',
          category: AnnouncementCategory.important,
          publishedAt: DateTime(2026, 11, 18, 9),
        ),
        Announcement(
          id: 'an-2',
          title: 'Thursday halaqa after Maghrib',
          description:
              'A short weekly study circle open to all students, with a different '
              'topic each week. Tea is served afterwards, and newcomers are always welcome.',
          category: AnnouncementCategory.events,
          publishedAt: DateTime(2026, 11, 16, 9),
          imageUrl: '$_imageBase/halaqa.jpg',
          eventTime: 'Thursdays after Maghrib',
          location: 'Masjid study room',
        ),
        // The Friday updates from the Jumu'ah screen (S4) also appear in the
        // feed under the Jumu'ah category.
        ...SampleData.fridayUpdates().map(Announcement.fromFridayUpdate),
        Announcement(
          id: 'an-3',
          title: 'Volunteers needed for masjid cleaning',
          description:
              'Help keep the masjid clean this Saturday morning. Speak to the masjid '
              'committee after Dhuhr to sign up.',
          category: AnnouncementCategory.general,
          publishedAt: DateTime(2026, 11, 9, 9),
          eventTime: 'Saturday, 10:00',
          location: 'Sabancı University Masjid',
        ),
        Announcement(
          id: 'an-4',
          title: 'Welcome tea for new students',
          description:
              'Meet other students and the masjid committee over tea after Isha. '
              'Everyone is welcome.',
          category: AnnouncementCategory.events,
          publishedAt: DateTime(2026, 11, 5, 9),
          imageUrl: '$_imageBase/tea.jpg',
          eventTime: 'Wednesday after Isha',
          location: 'Masjid entrance hall',
        ),
      ];
}
