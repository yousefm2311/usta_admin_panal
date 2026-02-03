import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payouts_service.dart';

class PayoutsController extends GetxController {
  final PayoutsService _service;
  PayoutsController({PayoutsService? service}) : _service = service ?? PayoutsService();

  final wallets = <Map<String, dynamic>>[].obs;
  final payout = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> loadWallets() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.walletSummary();
      final data = res.data;
      final normalized = _normalizeWallets(data);
      wallets.assignAll(normalized);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadPayout(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.payoutDetails(id);
      final data = res.data;
      payout.value = data is Map<String, dynamic> ? (data['payout'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _service.updatePayoutStatus(id, status);
      showSuccess('Success'.tr);
      await loadPayout(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  List<Map<String, dynamic>> _normalizeWallets(dynamic data) {
    final payload = _unwrapData(data);
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((e) => _normalizeWallet(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = <dynamic>[];
      final walletsList = payload['wallets'];
      if (walletsList is List) {
        list.addAll(walletsList);
      } else {
        final artisans = payload['artisans'];
        if (artisans is List) list.addAll(artisans);
        final customers = payload['customers'];
        if (customers is List) list.addAll(customers);
      }
      return list
          .whereType<Map>()
          .map((e) => _normalizeWallet(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  dynamic _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return data;
  }

  Map<String, dynamic> _normalizeWallet(Map<String, dynamic> raw) {
    final user = _unwrapMap(
      raw['user'] ??
          raw['owner'] ??
          raw['customer'] ??
          raw['artisan'] ??
          raw['userId'],
    );
    final owner = _firstNonEmpty([
      raw['owner'],
      raw['name'],
      user['name'],
      user['fullName'],
      user['email'],
      user['phone'],
      raw['email'],
      raw['phone'],
    ]);
    return {
      ...raw,
      if (owner.isNotEmpty) 'owner': owner,
      if (raw['type'] == null && user['type'] != null) 'type': user['type'],
      if (raw['user'] == null && user.isNotEmpty) 'user': user,
    };
  }

  Map<String, dynamic> _unwrapMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      final text = v?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}
