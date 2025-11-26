import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class SettingsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> getCommission() => _dio.get('/api/admin/settings/commission');

  Future<Response> updateCommission(double value) =>
      _dio.put('/api/admin/settings/commission', data: {'commission': value});
}
