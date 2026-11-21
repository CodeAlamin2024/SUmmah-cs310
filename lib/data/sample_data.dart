import 'package:flutter/material.dart';

import '../models/friday_update.dart';
import '../models/jumuah_info.dart';

/// Placeholder data for Step 2. Replaced by Firebase in Step 3.
class SampleData {
  SampleData._();

  static final JumuahInfo jumuahInfo = JumuahInfo(
    date: DateTime(2026, 11, 20),
    khutbahTime: '13:00',
    salahTime: '13:20',
    locationName: 'Sabancı University Masjid',
    locationNote:
        'Location description and directions on campus, to be confirmed with the masjid.',
    khutbahNote:
        'Khutbah language and topic will be listed here once the masjid shares them.',
  );

  static const List<CongregationNotice> congregationNotices = [
    CongregationNotice(
      icon: Icons.schedule,
      text: 'Arrive about ten minutes early: the main hall fills quickly.',
    ),
    CongregationNotice(
      icon: Icons.groups_outlined,
      text: 'Use the overflow area when the hall is full.',
    ),
    CongregationNotice(
      icon: Icons.do_not_disturb_on_outlined,
      text: 'Please keep phones on silent during the khutbah.',
    ),
  ];

  /// Returns a fresh, mutable list every call so removing a card on one
  /// screen never changes the original sample data.
  static List<FridayUpdate> fridayUpdates() => [
        FridayUpdate(
          id: 'fu-1',
          category: "Jumu'ah",
          title: "Arrive early for Jumu'ah",
          body:
              'The main hall fills quickly. Please arrive ten minutes before the khutbah.',
          date: DateTime(2026, 11, 13),
        ),
        FridayUpdate(
          id: 'fu-2',
          category: "Jumu'ah",
          title: 'Overflow area opens this Friday',
          body:
              'Volunteers will guide latecomers to the overflow room next to the main hall.',
          date: DateTime(2026, 11, 12),
        ),
        FridayUpdate(
          id: 'fu-3',
          category: "Jumu'ah",
          title: 'Wudu area cleaning at 12:30',
          body:
              'The wudu area will be closed for ten minutes before the khutbah for cleaning.',
          date: DateTime(2026, 11, 10),
        ),
      ];
}
