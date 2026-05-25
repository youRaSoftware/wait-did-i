import 'package:domain/models/models.dart';

import '../../dto/dto.dart';

class ExampleMapper {
  static ExampleModel toModel(ExampleDto dto) {
    return ExampleModel(
      id: dto.id,
      title: dto.title,
      description: dto.description,
    );
  }

  static ExampleDto toDto(ExampleModel model) {
    return ExampleDto(
      id: model.id,
      title: model.title,
      description: model.description,
    );
  }
}
