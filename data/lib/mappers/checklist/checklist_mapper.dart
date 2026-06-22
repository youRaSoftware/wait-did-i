import 'package:domain/domain.dart';

import '../../entities/checklist_entity.dart';
import '../../entities/checklist_item_entity.dart';

/// Pure entity <-> domain model conversion. No state.
class ChecklistMapper {
  static ChecklistModel toModel(ChecklistEntity e) {
    return ChecklistModel(
      id: e.id,
      name: e.name,
      shortName: e.shortName,
      emoji: e.emoji,
      lastChecked: e.lastChecked,
      items: e.items.map(_itemToModel).toList(),
    );
  }

  static ChecklistEntity toEntity(ChecklistModel m) {
    return ChecklistEntity(
      id: m.id,
      name: m.name,
      shortName: m.shortName,
      emoji: m.emoji,
      lastChecked: m.lastChecked,
      items: m.items.map(_itemToEntity).toList(),
    );
  }

  static ChecklistItemModel _itemToModel(ChecklistItemEntity e) {
    return ChecklistItemModel(
      id: e.id,
      name: e.name,
      isChecked: e.isChecked,
      checkedAt: e.checkedAt,
      photoPath: e.photoPath,
      photoRecommended: e.photoRecommended,
    );
  }

  static ChecklistItemEntity _itemToEntity(ChecklistItemModel m) {
    return ChecklistItemEntity(
      id: m.id,
      name: m.name,
      isChecked: m.isChecked,
      checkedAt: m.checkedAt,
      photoPath: m.photoPath,
      photoRecommended: m.photoRecommended,
    );
  }
}
