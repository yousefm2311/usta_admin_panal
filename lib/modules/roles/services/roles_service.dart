import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class RolesService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list() => _dio.get('/api/admin/roles');

  Future<Response> details(String id) => _dio.get('/api/admin/roles/$id');

  Future<Response> create(Map<String, dynamic> payload) => _dio.post('/api/admin/roles', data: payload);

  Future<Response> update(String id, Map<String, dynamic> payload) =>
      _dio.put('/api/admin/roles/$id', data: payload);

  Future<Response> delete(String id) => _dio.delete('/api/admin/roles/$id');
}
