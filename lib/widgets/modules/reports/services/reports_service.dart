import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class ReportsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list({Map<String, dynamic>? params}) =>
      _client.safe(() => _dio.get('/api/admin/reports', queryParameters: params));

  Future<Response> filter(Map<String, dynamic> params) =>
      _client.safe(() => _dio.get('/api/admin/reports/filter', queryParameters: params));

  Future<Response> details(String id) =>
      _client.safe(() => _dio.get('/api/admin/reports/$id'));

  Future<Response> reply(String id, String text) =>
      _client.safe(() => _dio.post('/api/admin/reports/$id/reply', data: {'text': text}));

  Future<Response> close(String id) =>
      _client.safe(() => _dio.put('/api/admin/reports/$id/close'));
}
