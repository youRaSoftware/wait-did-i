import 'package:dio/dio.dart';
import '../app_config.dart';

class DioConfig {
  final Dio dio;

  DioConfig({required AppConfig appConfig})
      : dio = Dio(
          BaseOptions(
            baseUrl: appConfig.apiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        ) {
    dio.interceptors.add(LogInterceptor());
  }
}
