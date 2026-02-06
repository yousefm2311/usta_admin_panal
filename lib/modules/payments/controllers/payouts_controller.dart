import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payouts_service.dart';

class PayoutsController extends GetxController {
  final PayoutsService _service;
  PayoutsController({PayoutsService? service})
    : _service = service ?? PayoutsService();

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
      final raw = data is Map<String, dynamic>
          ? (data['payout'] ?? data['data'] ?? data)
          : null;
      if (raw is Map<String, dynamic>) {
        final normalized = _normalizePayout(Map<String, dynamic>.from(raw));
        payout.value = normalized;
        await _hydratePayoutArtisanName(normalized);
      } else {
        payout.value = null;
      }
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

  String artisanNameFor(Map<String, dynamic> payout) {
    final direct = _sanitizeName(
      (payout['artisanName'] ?? payout['name'] ?? '').toString(),
    );
    if (direct.isNotEmpty) return direct;

    return _extractName(payout['artisan'] ?? payout['artisanId']);
  }

  String methodFor(Map<String, dynamic> payout) {
    return _firstNonEmpty([
      payout['methodResolved'],
      payout['method'],
      payout['paymentMethod'],
      payout['payment_method'],
      payout['type'],
      payout['channel'],
      payout['provider'],
    ]);
  }

  num amountFor(Map<String, dynamic> payout) {
    final raw = payout['amountResolved'] ?? payout['amount'];
    final direct = num.tryParse(raw?.toString() ?? '');
    if (direct != null) return direct;
    return _resolveAmount(payout);
  }

  String ibanFor(Map<String, dynamic> payout) {
    return _firstNonEmpty([
      payout['ibanResolved'],
      payout['iban'],
      payout['bankIban'],
      payout['accountIban'],
      payout['bank'] is Map<String, dynamic>
          ? (payout['bank'] as Map<String, dynamic>)['iban']
          : null,
      payout['bankAccount'] is Map<String, dynamic>
          ? (payout['bankAccount'] as Map<String, dynamic>)['iban']
          : null,
    ]);
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

  Map<String, dynamic> _normalizePayout(Map<String, dynamic> raw) {
    final id = _extractIdFromAny(raw['id'] ?? raw['_id']);
    final artisanId = _extractIdFromAny(raw['artisanId'] ?? raw['artisan']);
    final artisanName = _extractName(raw['artisan'] ?? raw['artisanName']);
    final amount = _resolveAmount(raw);
    final method = _firstNonEmpty([
      raw['method'],
      raw['paymentMethod'],
      raw['payment_method'],
      raw['type'],
      raw['channel'],
      raw['provider'],
    ]);
    final iban = _firstNonEmpty([
      raw['iban'],
      raw['bankIban'],
      raw['accountIban'],
      raw['bank'] is Map<String, dynamic>
          ? (raw['bank'] as Map<String, dynamic>)['iban']
          : null,
      raw['bankAccount'] is Map<String, dynamic>
          ? (raw['bankAccount'] as Map<String, dynamic>)['iban']
          : null,
    ]);

    return {
      ...raw,
      if (id.isNotEmpty) 'id': id,
      if (artisanId.isNotEmpty) 'artisanId': artisanId,
      if (artisanName.isNotEmpty) 'artisanName': artisanName,
      'amountResolved': amount,
      if (method.isNotEmpty) 'methodResolved': method,
      if (iban.isNotEmpty) 'ibanResolved': iban,
    };
  }

  Future<void> _hydratePayoutArtisanName(Map<String, dynamic> current) async {
    final existingName = artisanNameFor(current);
    if (existingName.isNotEmpty) return;

    final artisanId = _extractIdFromAny(
      current['artisanId'] ?? current['artisan'],
    );
    if (artisanId.isEmpty) return;

    try {
      final artisans = await _service.fetchArtisans();
      String name = '';
      for (final raw in artisans) {
        final artisan = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final id = _extractIdFromAny(artisan['_id'] ?? artisan['id']);
        if (id != artisanId) continue;
        name = _extractName(artisan);
        if (name.isNotEmpty) break;
      }
      if (name.isEmpty) return;
      payout.value = {...current, 'artisanName': name};
    } catch (_) {
      // Keep silent fallback if artisans endpoint fails.
    }
  }

  num _resolveAmount(Map<String, dynamic> raw) {
    final amount = num.tryParse((raw['amount'] ?? '').toString());
    if (amount != null && amount != 0) return amount;

    final finalAmount = num.tryParse((raw['finalAmount'] ?? '').toString());
    if (finalAmount != null && finalAmount != 0) return finalAmount;

    final value = num.tryParse((raw['value'] ?? '').toString());
    if (value != null && value != 0) return value;

    final debit = num.tryParse((raw['debit'] ?? '').toString());
    if (debit != null && debit != 0) return debit;

    final credit = num.tryParse((raw['credit'] ?? '').toString());
    if (credit != null && credit != 0) return credit;

    return 0;
  }

  String _extractIdFromAny(dynamic value) {
    if (value == null) return '';
    if (value is String || value is num) return value.toString();
    if (value is Map<String, dynamic>) {
      final nested = value['_id'] ?? value['id'] ?? value['value'];
      if (nested == null) return '';
      return nested.toString();
    }
    return '';
  }

  String _extractName(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      return _sanitizeName(value);
    }
    if (value is Map<String, dynamic>) {
      final rawName =
          value['name'] ??
          value['fullName'] ??
          value['displayName'] ??
          value['userName'] ??
          value['username'] ??
          value['email'] ??
          value['phone'];
      return _sanitizeName(rawName?.toString() ?? '');
    }
    return '';
  }

  String _sanitizeName(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value)) return '';
    return value;
  }
}
