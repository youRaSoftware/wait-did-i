import 'package:domain/domain.dart';
import '../dto/dto.dart';
import '../mappers/mappers.dart';
import '../providers/api/api_providers.dart';

class ExampleRepositoryImpl implements ExampleRepository {
  final ExampleApiProvider _apiProvider;

  ExampleRepositoryImpl({
    required ExampleApiProvider apiProvider,
  }) : _apiProvider = apiProvider;

  @override
  Future<ExampleModel> getExample() async {
    final ExampleDto dto = await _apiProvider.getExample();
    return ExampleMapper.toModel(dto);
  }

  @override
  Future<void> saveExample(ExampleModel example) async {
    final ExampleDto dto = ExampleMapper.toDto(example);
    // TODO: Implement save logic using dto
    // await _apiProvider.saveExample(dto);
    // Temporary: use dto to avoid unused variable warning
    final String _ = dto.id;
  }
}
