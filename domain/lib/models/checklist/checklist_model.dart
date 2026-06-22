import 'package:freezed_annotation/freezed_annotation.dart';

import 'checklist_item_model.dart';

part 'checklist_model.freezed.dart';

/// A checklist (e.g. "Leaving home"). [shortName] is the tab label ("Home"),
/// [name] the full title shown above the items.
@freezed
abstract class ChecklistModel with _$ChecklistModel {
  const factory ChecklistModel({
    required String id,
    required String name,
    required String shortName,
    required String emoji,
    @Default(<ChecklistItemModel>[]) List<ChecklistItemModel> items,
    DateTime? lastChecked,
  }) = _ChecklistModel;

  const ChecklistModel._();

  int get total => items.length;
  int get checkedCount => items.where((ChecklistItemModel i) => i.isChecked).length;
  double get progress => total == 0 ? 0 : checkedCount / total;

  /// Some — but not all — items are checked.
  bool get isChecking => checkedCount > 0 && checkedCount < total;

  /// Every item is checked.
  bool get allDone => total > 0 && checkedCount == total;
}
