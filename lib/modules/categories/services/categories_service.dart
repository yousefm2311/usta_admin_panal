import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class CategoriesService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list() => _client.safe(() => _dio.get('/api/admin/categories'));

  Future<Response> create({required String name, required String icon}) {
    return _client.safe(() => _dio.post('/api/admin/categories', data: {'name': name, 'icon': icon}));
  }

  Future<Response> delete(String id) => _client.safe(() => _dio.delete('/api/admin/categories/$id'));
}
