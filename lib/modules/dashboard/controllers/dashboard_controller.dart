import 'package:get/get.dart';

import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service;
  DashboardController({DashboardService? service}) : _service = service ?? DashboardService();

  final stats = Rxn<Map<String, dynamic>>();
  final activities = <dynamic>[].obs;
  final topArtisans = <dynamic>[].obs;
  final latestRequests = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    loading.value = true;
    error.value = null;
    try {
      stats.value = await _service.fetchStats();
      activities.assignAll(await _service.fetchActivities());
      topArtisans.assignAll(await _service.fetchTopArtisans());
      latestRequests.assignAll(await _service.fetchLatestRequests());
      await _ensureMonthlyPerformance();
    } catch (e) {
      // avoid breaking UI on missing optional endpoints
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _ensureMonthlyPerformance() async {
    final current = stats.value ?? <String, dynamic>{};
    final monthly =
        (current['monthly'] ?? current['analytics'] ?? current['chart'] ?? [])
            as List<dynamic>;
    if (monthly.isNotEmpty) return;

    try {
      final requests = await _service.fetchRequests();
      final computed = _computeMonthlyRequests(requests);
      if (computed.isEmpty) return;
      stats.value = {...current, 'monthly': computed};
    } catch (_) {
      // keep existing stats if fallback fails
    }
  }

  List<Map<String, dynamic>> _computeMonthlyRequests(List<dynamic> requests) {
    if (requests.isEmpty) return [];
    final buckets = <String, Map<String, dynamic>>{};
    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final createdAt = req['createdAt'] ?? req['created'] ?? req['date'];
      final date = DateTime.tryParse(createdAt?.toString() ?? '');
      if (date == null) continue;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final current = buckets.putIfAbsent(key, () {
        return {
          'year': date.year,
          'monthIndex': date.month,
          'month': _monthLabel(date.month),
          'requests': 0,
        };
      });
      current['requests'] = (current['requests'] as int) + 1;
    }
    final list = buckets.values.toList();
    list.sort((a, b) {
      final ay = a['year'] as int? ?? 0;
      final by = b['year'] as int? ?? 0;
      if (ay != by) return ay.compareTo(by);
      final am = a['monthIndex'] as int? ?? 0;
      final bm = b['monthIndex'] as int? ?? 0;
      return am.compareTo(bm);
    });
    return list;
  }

  String _monthLabel(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return month.toString();
    return names[month - 1];
  }
}
