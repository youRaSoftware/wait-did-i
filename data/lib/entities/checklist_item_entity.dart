/// Hive persistence model for a checklist item. Plain class — hive_ce generates
/// the adapter from the constructor fields (see `hive/hive_adapters.dart`).
class ChecklistItemEntity {
  ChecklistItemEntity({
    required this.id,
    required this.name,
    required this.isChecked,
    required this.checkedAt,
    required this.photoPath,
    required this.photoRecommended,
  });

  final String id;
  final String name;
  final bool isChecked;
  final DateTime? checkedAt;
  final String? photoPath;
  final bool photoRecommended;
}
