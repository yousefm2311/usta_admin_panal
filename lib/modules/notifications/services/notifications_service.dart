import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class NotificationsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> send(Map<String, dynamic> payload) => _dio.post('/api/admin/notifications', data: payload);

  Future<Response> list() => _dio.get('/api/admin/notifications');

  Future<Response> templates() => _dio.get('/api/admin/notifications/templates');

  Future<Response> history() => _dio.get('/api/admin/notifications/history');

  Future<Response> createTemplate(Map<String, dynamic> payload) =>
      _dio.post('/api/admin/notifications/templates', data: payload);

  Future<Response> updateTemplate(String id, Map<String, dynamic> payload) =>
      _dio.put('/api/admin/notifications/templates/$id', data: payload);

  Future<Response> deleteTemplate(String id) => _dio.delete('/api/admin/notifications/templates/$id');

  Future<Response> deleteNotification(String id) => _dio.delete('/api/admin/notifications/$id');
}
