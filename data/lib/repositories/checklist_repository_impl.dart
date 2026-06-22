import 'package:domain/domain.dart';

import '../entities/checklist_entity.dart';
import '../mappers/mappers.dart';
import '../providers/hive/checklist_hive_provider.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  ChecklistRepositoryImpl({required ChecklistHiveProvider provider}) : _provider = provider;

  final ChecklistHiveProvider _provider;

  @override
  Future<List<ChecklistModel>> loadLists() async {
    return _provider.getAll().map(ChecklistMapper.toModel).toList();
  }

  @override
  Future<ChecklistModel> toggleItem({required String listId, required String itemId}) async {
    final ChecklistEntity? entity = _provider.get(listId);
    if (entity == null) {
      throw StateError('Checklist "$listId" not found');
    }
    final ChecklistModel list = ChecklistMapper.toModel(entity);
    final DateTime now = DateTime.now();
    final List<ChecklistItemModel> items = list.items.map((ChecklistItemModel i) {
      if (i.id != itemId) return i;
      final bool willCheck = !i.isChecked;
      return i.copyWith(isChecked: willCheck, checkedAt: willCheck ? now : null);
    }).toList();
    final ChecklistModel updated = list.copyWith(items: items, lastChecked: now);
    await _provider.put(ChecklistMapper.toEntity(updated));
    return updated;
  }

  @override
  Future<void> seedDefaultsIfNeeded() async {
    if (_provider.isSeeded) return;
    for (final ChecklistModel list in _defaultLists()) {
      await _provider.put(ChecklistMapper.toEntity(list));
    }
    await _provider.markSeeded();
  }

  /// MVP starter lists (Home / Bed / Car), matching the reference tabs. English
  /// sample content — the user can rename items later; UI chrome is localized.
  List<ChecklistModel> _defaultLists() {
    return const <ChecklistModel>[
      ChecklistModel(
        id: 'leaving_home',
        name: 'Leaving home',
        shortName: 'Home',
        emoji: '🏠',
        items: <ChecklistItemModel>[
          ChecklistItemModel(id: 'front_door', name: 'Front door', photoRecommended: true),
          ChecklistItemModel(id: 'stove_off', name: 'Stove off'),
          ChecklistItemModel(id: 'windows_closed', name: 'Windows closed'),
        ],
      ),
      ChecklistModel(
        id: 'before_bed',
        name: 'Before bed',
        shortName: 'Bed',
        emoji: '🌙',
        items: <ChecklistItemModel>[
          ChecklistItemModel(id: 'bed_doors_locked', name: 'Doors locked'),
          ChecklistItemModel(id: 'bed_lights_off', name: 'Lights off'),
          ChecklistItemModel(id: 'bed_alarm_set', name: 'Alarm set'),
        ],
      ),
      ChecklistModel(
        id: 'car',
        name: 'Car',
        shortName: 'Car',
        emoji: '🚗',
        items: <ChecklistItemModel>[
          ChecklistItemModel(id: 'car_locked', name: 'Car locked'),
          ChecklistItemModel(id: 'car_lights_off', name: 'Lights off'),
          ChecklistItemModel(id: 'car_windows_up', name: 'Windows up'),
        ],
      ),
    ];
  }
}
