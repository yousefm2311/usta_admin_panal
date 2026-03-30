import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _service;
  AnalyticsController({AnalyticsService? service}) : _service = service ?? AnalyticsService();

  final daily = <dynamic>[].obs;
  final revenue = Rxn<Map<String, dynamic>>();
  final activeUsers = Rxn<Map<String, dynamic>>();
  final avgRating = RxnDouble();
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.daily();
      final data = res.data;
      if (data is List) {
        daily.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        daily.assignAll(data['data'] ?? data['daily'] ?? []);
      } else {
        daily.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    }
    await _loadDerivedAnalytics();
    try {
      final res = await _service.revenue();
      final data = res.data;
      revenue.value = _asMap(data);
    } catch (_) {
      revenue.value = null;
    }
    try {
      final res = await _service.activeUsers();
      final data = res.data;
      activeUsers.value = _asMap(data);
    } catch (_) {
      activeUsers.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadDerivedAnalytics() async {
    try {
      final results = await Future.wait([
        _service.fetchRequests(),
        _service.fetchReviews(),
      ]);
      final requests = results[0];
      final reviews = results[1];
      final computedDaily = _computeMonthlyRequests(requests);
      if (computedDaily.isNotEmpty) {
        daily.assignAll(computedDaily);
      }
      final computedRevenue = _computeTotalRevenue(requests);
      if (computedRevenue != null) {
        revenue.value = {'total': computedRevenue};
      }
      final computedActive = _computeActiveUsers(requests);
      if (computedActive != null) {
        activeUsers.value = {'count': computedActive};
      }
      avgRating.value = _computeAvgRating(reviews);
    } catch (_) {
      // Keep API-provided analytics if fallback fails.
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
          'earnings': 0.0,
        };
      });
      current['requests'] = (current['requests'] as int) + 1;
      final price = _extractRequestPrice(req);
      if (price != null && price > 0) {
        current['earnings'] = (current['earnings'] as double) + price;
      }
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

  double? _computeTotalRevenue(List<dynamic> requests) {
    double total = 0;
    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final price = _extractRequestPrice(req);
      if (price != null && price > 0) {
        total += price;
      }
    }
    return total > 0 ? total : 0;
  }

  int? _computeActiveUsers(List<dynamic> requests) {
    if (requests.isEmpty) return 0;
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));
    final customers = <String>{};
    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final createdAt = req['createdAt'] ?? req['created'] ?? req['date'];
      final date = DateTime.tryParse(createdAt?.toString() ?? '');
      if (date == null || date.isBefore(cutoff)) continue;
      final customerId =
          (req['customerId']?['_id'] ?? req['customerId'] ?? req['customer']?['_id'] ?? req['customer'])
              ?.toString() ??
          '';
      if (customerId.isNotEmpty) {
        customers.add(customerId);
      }
    }
    return customers.length;
  }

  double _computeAvgRating(List<dynamic> reviews) {
    double total = 0;
    int count = 0;
    for (final raw in reviews) {
      final review = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final rating = double.tryParse((review['rating'] ?? 0).toString()) ?? 0;
      if (rating > 0) {
        total += rating;
        count += 1;
      }
    }
    if (count == 0) return 0;
    return total / count;
  }

  double? _extractRequestPrice(Map<String, dynamic> req) {
    final candidate =
        req['agreedPrice'] ??
        req['price'] ??
        req['amount'] ??
        req['total'] ??
        req['pricing']?['proposedPrice'];
    return double.tryParse(candidate?.toString() ?? '');
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

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
    }
    return null;
  }
}
