import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class RolesService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list() => _client.safe(() => _dio.get('/api/admin/roles'));

  Future<Response> details(String id) => _client.safe(() => _dio.get('/api/admin/roles/$id'));

  Future<Response> create(Map<String, dynamic> payload) => _client.safe(() => _dio.post('/api/admin/roles', data: payload));

  Future<Response> createAdminForRole(
      {required String roleName, required String email, required String password}) {
    return _client.safe(() => _dio.post('/api/admin/create', data: {
      'name': roleName,
      'email': email,
      'password': password,
      'role': roleName,
    }));
  }

  Future<Response> update(String id, Map<String, dynamic> payload) =>
      _client.safe(() => _dio.put('/api/admin/roles/$id', data: payload));

  Future<Response> delete(String id) => _client.safe(() => _dio.delete('/api/admin/roles/$id'));
}
