import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../state/app_state.dart';
import '../utils/app_routes.dart';
import 'announcements_screen.dart';
import 'home_screen.dart';
import 'jumuah_screen.dart';
import 'timetable_screen.dart';

/// Bottom-navigation shell: Home, Timetable, Announcements, Jumu'ah.
///
/// Tabs are kept alive in an [IndexedStack] so scroll position and removed
/// cards survive tab switches.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  static const int homeTab = 0;
  static const int timetableTab = 1;
  static const int announcementsTab = 2;
  static const int jumuahTab = 3;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  void _goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      HomeScreen(
        onOpenTimetable: () => _goToTab(MainShell.timetableTab),
        onOpenAnnouncements: () {
          AppState.instance.setFilter(null);
          _goToTab(MainShell.announcementsTab);
        },
        onOpenJumuah: () => _goToTab(MainShell.jumuahTab),
      ), // S1
      const TimetableScreen(), // S2
      const AnnouncementsScreen(), // S3
      JumuahScreen(
        // "All Friday updates" opens S3 already filtered to Jumu'ah.
        onSeeAllUpdates: () {
          AppState.instance.setFilter(AnnouncementCategory.jumuah);
          _goToTab(MainShell.announcementsTab);
        },
        // Tapping a Friday update opens it on the detail screen (S3.1).
        onOpenUpdate: (update) => Navigator.of(context).pushNamed(
          AppRoutes.announcementDetail,
          arguments: Announcement.fromFridayUpdate(update),
        ),
      ), // S4
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          NavigationDestination(
            icon: Icon(Icons.mosque_outlined),
            selectedIcon: Icon(Icons.mosque),
            label: "Jumu'ah",
          ),
        ],
      ),
    );
  }
}
