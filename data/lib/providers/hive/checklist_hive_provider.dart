import 'package:hive_ce/hive_ce.dart';

import '../../entities/checklist_entity.dart';

/// Thin wrapper over the Hive boxes that hold checklists + a one-time "seeded" flag.
class ChecklistHiveProvider {
  ChecklistHiveProvider({required Box<ChecklistEntity> box, required Box<dynamic> metaBox})
    : _box = box,
      _meta = metaBox;

  final Box<ChecklistEntity> _box;
  final Box<dynamic> _meta;

  // Bump the suffix to force a re-seed (e.g. when the default lists change).
  static const String _seededKey = 'checklists_seeded_v2';

  List<ChecklistEntity> getAll() => _box.values.toList();

  ChecklistEntity? get(String id) => _box.get(id);

  Future<void> put(ChecklistEntity entity) => _box.put(entity.id, entity);

  bool get isSeeded => _meta.get(_seededKey, defaultValue: false) as bool;

  Future<void> markSeeded() => _meta.put(_seededKey, true);
}
