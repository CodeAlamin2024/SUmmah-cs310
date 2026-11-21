/// A short Jumu'ah-related update shown as a card on the Jumu'ah screen (S4).
///
/// In Step 3 these will come from Firestore; for Step 2 we use sample data.
class FridayUpdate {
  const FridayUpdate({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    required this.date,
    this.isDemo = true,
  });

  final String id;
  final String category;
  final String title;
  final String body;
  final DateTime date;

  /// True while the data is placeholder content.
  final bool isDemo;
}
