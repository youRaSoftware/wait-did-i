import '../models/models.dart';

abstract class ExampleRepository {
  Future<ExampleModel> getExample();
  Future<void> saveExample(ExampleModel example);
}
