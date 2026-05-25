import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../../dto/dto.dart';

class ExampleApiProvider {
  final Dio _dio;

  ExampleApiProvider(this._dio);

  Future<ExampleDto> getExample() async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get<Map<String, dynamic>>('/example');
      final Map<String, dynamic>? data = response.data;
      if (data == null) {
        throw Exception('Response data is null');
      }
      return ExampleDto.fromJson(data);
    } catch (e) {
      // Return mock data if connection fails
      return const ExampleDto(
        id: 'mock-id-123',
        title: 'Mock Example Title',
        description: 'This is a mock response. API connection failed.',
      );
    }
  }
}
