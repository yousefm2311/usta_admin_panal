import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class NotificationsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> send(Map<String, dynamic> payload) => _dio.post('/api/admin/notifications', data: payload);

  Future<Response> templates() => _dio.get('/api/admin/notifications/templates');

  Future<Response> history() => _dio.get('/api/admin/notifications/history');
}
