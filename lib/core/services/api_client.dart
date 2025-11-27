import 'package:dio/dio.dart';

import 'api_exceptions.dart';
import 'http_client.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final HttpClient http;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    http = HttpClient();
  }

  Dio get dio => http.dio;

  Future<Response<T>> safe<T>(Future<Response<T>> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }
}
