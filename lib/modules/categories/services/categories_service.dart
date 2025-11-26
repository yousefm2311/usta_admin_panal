import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class CategoriesService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list() => _dio.get('/api/admin/categories');

  Future<Response> create({required String name, required String icon}) {
    return _dio.post('/api/admin/categories', data: {'name': name, 'icon': icon});
  }

  Future<Response> delete(String id) => _dio.delete('/api/admin/categories/$id');
}
