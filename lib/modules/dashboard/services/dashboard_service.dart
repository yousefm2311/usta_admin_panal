import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class DashboardService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> fetchStats() async {
    // Primary endpoint available on current backend
    try {
      final altDash = await _client.safe(
        () => _dio.get('/api/admin/dashboard'),
      );
      final d = altDash.data;
      if (d is Map<String, dynamic>) return d['data'] ?? d;
    } catch (_) {}
    // Fallback to older stats endpoint if present
    try {
      final res = await _client.safe(
        () => _dio.get('/api/admin/dashboard/stats'),
      );
      final data = res.data;
      return data is Map<String, dynamic>
          ? (data['data'] ?? data) as Map<String, dynamic>
          : {};
    } catch (_) {}
    // Final fallback to analytics daily
    try {
      final alt = await _client.safe(
        () => _dio.get('/api/admin/analytics/daily'),
      );
      final data = alt.data;
      if (data is Map<String, dynamic>) return data['data'] ?? data;
      return {'daily': data};
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> fetchActivities() async {
    // Prefer dashboard activity endpoint when available.
    try {
      final res = await _client.safe(
        () => _dio.get('/api/admin/dashboard/activity'),
      );
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>)
        return (data['data'] ?? data['logs'] ?? []) as List<dynamic>;
    } catch (_) {}
    // Fallback to activity logs endpoint.
    try {
      final alt = await _client.safe(
        () => _dio.get('/api/admin/logs/activity'),
      );
      final data = alt.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>)
        return (data['data'] ?? data['logs'] ?? []) as List<dynamic>;
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> fetchRequests() async {
    final res = await _client.safe(() => _dio.get('/api/admin/requests'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['requests'] ?? data['data'] ?? data['orders'] ?? [])
          as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchTopArtisans() async {
    // Prefer AI top-artisans endpoint which exists on backend
    try {
      final res = await _client.safe(
        () => _dio.get('/api/admin/ai/top-artisans'),
      );
      final data = res.data;
      if (data is List) return _hydrateTopArtisans(data);
      if (data is Map<String, dynamic>) {
        final list = _asList(data['data'] ?? data['top']);
        return _hydrateTopArtisans(list);
      }
    } catch (_) {}
    // Fallback to dashboard top-artisans
    try {
      final res = await _client.safe(
        () => _dio.get('/api/admin/dashboard/top-artisans'),
      );
      final data = res.data;
      if (data is List) return _hydrateTopArtisans(data);
      if (data is Map<String, dynamic>) {
        final list = _asList(data['data'] ?? data['top']);
        return _hydrateTopArtisans(list);
      }
    } catch (_) {}
    // Fallback to list artisans and take top 5
    try {
      final alt = await _client.safe(() => _dio.get('/api/admin/artisans'));
      if (alt.data is List) {
        return (alt.data as List<dynamic>).take(5).toList();
      } else if (alt.data is Map<String, dynamic>) {
        final list =
            (alt.data['artisans'] ?? alt.data['data'] ?? alt.data['top'] ?? [])
                as List<dynamic>;
        return list.take(5).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> fetchLatestRequests() async {
    try {
      final res = await _client.safe(
        () => _dio.get(
          '/api/admin/requests',
          queryParameters: {'page': 1, 'perPage': 10},
        ),
      );
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>)
        return (data['requests'] ?? data['data'] ?? []) as List<dynamic>;
      return [];
    } catch (_) {
      return [];
    }
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    if (value is List) return value.cast<dynamic>();
    return [];
  }

  Future<List<dynamic>> _hydrateTopArtisans(List<dynamic> source) async {
    if (source.isEmpty) return source;

    final normalized = source.map(_asMap).toList();
    final ids = <String>{};
    for (final item in normalized) {
      final artisan = _asOptionalMap(item['artisan']);
      final name = _pickText([
        artisan?['name'],
        item['name'],
        item['artisanName'],
      ]);
      if (name.isNotEmpty) continue;
      final id = _pickText([
        item['artisanId'],
        artisan?['_id'],
        artisan?['id'],
        item['_id'],
        item['id'],
      ]);
      if (id.isNotEmpty) ids.add(id);
    }

    if (ids.isEmpty) return normalized;

    final byId = <String, Map<String, dynamic>>{};
    final detailsList = await Future.wait(
      ids.map((id) async => (id, await _fetchArtisanDetails(id))),
    );
    for (final entry in detailsList) {
      final id = entry.$1;
      final details = entry.$2;
      if (details != null && details.isNotEmpty) byId[id] = details;
    }

    if (byId.isEmpty) return normalized;

    for (final item in normalized) {
      final artisan = _asOptionalMap(item['artisan']);
      final id = _pickText([
        item['artisanId'],
        artisan?['_id'],
        artisan?['id'],
        item['_id'],
        item['id'],
      ]);
      if (id.isEmpty) continue;
      final found = byId[id];
      if (found == null) continue;
      item['artisan'] = {...found, if (artisan != null) ...artisan};
      item['artisanId'] = id;
    }

    return normalized;
  }

  Future<Map<String, dynamic>?> _fetchArtisanDetails(String id) async {
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/artisans/$id'));
      final data = res.data;
      if (data is Map<String, dynamic>) {
        final raw = data['artisan'] ?? data['data'] ?? data;
        return _asOptionalMap(raw);
      }
    } catch (_) {}
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return {...value};
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic>? _asOptionalMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _pickText(Iterable<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return '';
  }
}
