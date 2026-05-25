import 'dart:async';

import 'package:core/core.dart';

import '../models/models.dart';
import '../repositories/example_repository.dart';

class ExampleService {
  final ExampleRepository _repository;

  ExampleService._internal() : _repository = appLocator<ExampleRepository>() {
    _initializeAsync();
  }

  static ExampleService get instance => _instance;
  static final ExampleService _instance = ExampleService._internal();

  final Completer<void> _completer = Completer<void>();
  Future<void> get initialize => _completer.future;

  void _initializeAsync() {
    Future<void>(() async {
      try {
        // Initialization logic
        _completer.complete();
      } catch (e) {
        _completer.completeError(e);
      }
    });
  }

  Future<ExampleModel> getExample() async {
    return _repository.getExample();
  }
}
