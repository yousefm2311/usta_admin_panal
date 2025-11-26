import 'package:dio/dio.dart';
import 'http_client.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final HttpClient http;

  factory ApiClient() => _instance;

  ApiClient._internal() {
    http = HttpClient();
  }

  Dio get dio => http.dio;
}
