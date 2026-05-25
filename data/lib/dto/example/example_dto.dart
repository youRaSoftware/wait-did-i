import 'package:freezed_annotation/freezed_annotation.dart';

part 'example_dto.freezed.dart';
part 'example_dto.g.dart';

@freezed
abstract class ExampleDto with _$ExampleDto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ExampleDto({
    @Default('') String id,
    @Default('') String title,
    @Default('') String description,
  }) = _ExampleDto;

  const ExampleDto._();

  factory ExampleDto.fromJson(Map<String, dynamic> json) => _$ExampleDtoFromJson(json);
}
