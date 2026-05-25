import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_model.freezed.dart';

@freezed
abstract class ExampleModel with _$ExampleModel {
  const factory ExampleModel({
    required String id,
    required String title,
    required String description,
  }) = _ExampleModel;

  const ExampleModel._();

  factory ExampleModel.empty() => const ExampleModel(
        id: '',
        title: '',
        description: '',
      );
}
