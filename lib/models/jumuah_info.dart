import 'package:flutter/widgets.dart';

/// Details of the upcoming Friday prayer shown at the top of S4.
class JumuahInfo {
  const JumuahInfo({
    required this.date,
    required this.khutbahTime,
    required this.salahTime,
    required this.locationName,
    required this.locationNote,
    required this.khutbahNote,
  });

  final DateTime date;
  final String khutbahTime; // "13:00"
  final String salahTime; // "13:20"
  final String locationName;
  final String locationNote;
  final String khutbahNote;
}

/// One line in the "Congregation notices" card.
class CongregationNotice {
  const CongregationNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;
}
