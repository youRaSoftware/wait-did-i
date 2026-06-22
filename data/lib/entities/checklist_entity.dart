import 'checklist_item_entity.dart';

/// Hive persistence model for a checklist. Plain class — hive_ce generates the
/// adapter from the constructor fields (see `hive/hive_adapters.dart`).
class ChecklistEntity {
  ChecklistEntity({
    required this.id,
    required this.name,
    required this.shortName,
    required this.emoji,
    required this.items,
    required this.lastChecked,
  });

  final String id;
  final String name;
  final String shortName;
  final String emoji;
  final List<ChecklistItemEntity> items;
  final DateTime? lastChecked;
}
