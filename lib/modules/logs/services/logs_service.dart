import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class LogsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> activity({int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _dio.get('/api/admin/logs/activity', queryParameters: params);
  }

  Future<Response> health() => _dio.get('/api/admin/logs/health');
}
