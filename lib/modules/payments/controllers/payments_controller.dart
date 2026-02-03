import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payments_service.dart';

class PaymentsController extends GetxController {
  final PaymentsService _service;
  PaymentsController({PaymentsService? service}) : _service = service ?? PaymentsService();

  final transactions = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final filter = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({Map<String, dynamic>? params, bool reset = false}) async {
    loading.value = true;
    error.value = null;
    try {
      if (reset) {
        filter.clear();
      }
      if (params != null) {
        filter
          ..clear()
          ..addAll(params);
      }
      final query = filter.isEmpty ? null : Map<String, dynamic>.from(filter);
      final res =
          query == null ? await _service.transactions() : await _service.filter(query);
      final data = res.data;
      final normalized = _normalizeList(_unwrapData(data));
      transactions.assignAll(normalized);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  dynamic _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['payments'] ??
          data['transactions'] ??
          data['items'] ??
          data['results'] ??
          data['data'] ??
          data;
    }
    return data;
  }

  List<Map<String, dynamic>> _normalizeList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      return [Map<String, dynamic>.from(data)];
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> applyFilter(Map<String, dynamic> params) async {
    await loadTransactions(params: params);
  }

  Future<void> clearFilter() async {
    await loadTransactions(reset: true);
  }
}
