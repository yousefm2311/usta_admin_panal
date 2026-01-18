import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class SettingsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> getCommission() => _client.safe(() => _dio.get('/api/admin/settings/commission'));

  Future<Response> updateCommission(double value) =>
      _client.safe(() => _dio.put('/api/admin/settings/commission', data: {'commission': value}));

  Future<Response> getGeneral() => _client.safe(() => _dio.get('/api/admin/settings/general'));

  Future<Response> updateGeneral(Map<String, dynamic> body) =>
      _client.safe(() => _dio.put('/api/admin/settings/general', data: body));

  Future<Response> updateFeatures(Map<String, dynamic> body) =>
      _client.safe(() => _dio.put('/api/admin/settings/features', data: body));

  Future<Response> getAbout() => _client.safe(() => _dio.get('/api/admin/settings/about'));

  Future<Response> updateAbout(String about) =>
      _client.safe(() => _dio.put('/api/admin/settings/about', data: {'about': about}));

  Future<Response> getSecurity() => _client.safe(() => _dio.get('/api/admin/settings/security'));

  Future<Response> uploadLogo(FormData formData) =>
      _client.safe(() => _dio.post('/api/admin/uploads/logo', data: formData));
}
