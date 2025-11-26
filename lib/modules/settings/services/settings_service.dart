import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class SettingsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getCommission() => _dio.get('/api/admin/settings/commission');

  Future<Response> updateCommission(double value) =>
      _dio.put('/api/admin/settings/commission', data: {'commission': value});

  Future<Response> getGeneral() => _dio.get('/api/admin/settings/general');

  Future<Response> updateGeneral(Map<String, dynamic> body) =>
      _dio.put('/api/admin/settings/general', data: body);

  Future<Response> uploadLogo(FormData formData) =>
      _dio.post('/api/admin/uploads/logo', data: formData);
}
