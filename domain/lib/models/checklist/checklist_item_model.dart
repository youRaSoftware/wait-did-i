import 'package:freezed_annotation/freezed_annotation.dart';

part 'checklist_item_model.freezed.dart';

/// A single checklist item (e.g. "Front door"). Checking it stamps [checkedAt];
/// [photoPath] is set only when the user attached a photo confirmation.
@freezed
abstract class ChecklistItemModel with _$ChecklistItemModel {
  const factory ChecklistItemModel({
    required String id,
    required String name,
    @Default(false) bool isChecked,
    DateTime? checkedAt,
    String? photoPath,
    @Default(false) bool photoRecommended,
  }) = _ChecklistItemModel;

  const ChecklistItemModel._();

  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;
}
