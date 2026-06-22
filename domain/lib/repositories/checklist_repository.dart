import '../models/models.dart';

/// Local-first checklist storage. Implementation persists via hive_ce.
abstract class ChecklistRepository {
  /// All checklists, ordered.
  Future<List<ChecklistModel>> loadLists();

  /// Toggle one item's checked state (stamping/clearing its time) and return the
  /// updated list it belongs to.
  Future<ChecklistModel> toggleItem({required String listId, required String itemId});

  /// Seed the default "Leaving home" list on first ever run. No-op afterwards,
  /// so the empty state stays reachable if the user later deletes everything.
  Future<void> seedDefaultsIfNeeded();
}
