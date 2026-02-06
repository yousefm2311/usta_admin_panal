import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/withdrawals_service.dart';

class WithdrawalsController extends GetxController {
  final WithdrawalsService _service;
  WithdrawalsController({WithdrawalsService? service})
    : _service = service ?? WithdrawalsService();

  final withdrawals = <dynamic>[].obs;
  final artisanNamesById = <String, String>{}.obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list();
      final normalized = _normalizeWithdrawals(res.data);
      withdrawals.assignAll(normalized);
      await _hydrateArtisanNames(normalized);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> approve(String id) async {
    try {
      await _service.approve(id);
      showSuccess('Success'.tr);
      await loadWithdrawals();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> reject(String id) async {
    try {
      await _service.reject(id);
      showSuccess('Rejected'.tr);
      await loadWithdrawals();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  String idFor(Map<String, dynamic> withdrawal) {
    return _extractIdFromAny(withdrawal['id'] ?? withdrawal['_id']);
  }

  String artisanNameFor(Map<String, dynamic> withdrawal) {
    final fromMap = _sanitizeName(
      (withdrawal['artisanName'] ?? withdrawal['artisan_name'] ?? '')
          .toString(),
    );
    if (fromMap.isNotEmpty) return fromMap;

    final direct = _extractName(
      withdrawal['artisan'] ??
          withdrawal['artisanId'] ??
          withdrawal['user'] ??
          withdrawal['owner'],
    );
    if (direct.isNotEmpty) return direct;

    final artisanId = _extractIdFromAny(
      withdrawal['artisanId'] ?? withdrawal['artisan'],
    );
    if (artisanId.isNotEmpty) {
      final mapped = _sanitizeName(artisanNamesById[artisanId] ?? '');
      if (mapped.isNotEmpty) return mapped;
    }
    return '';
  }

  num amountFor(Map<String, dynamic> withdrawal) {
    final raw = withdrawal['amountResolved'] ?? withdrawal['amount'];
    final direct = num.tryParse(raw?.toString() ?? '');
    if (direct != null) return direct;
    return _resolveAmount(withdrawal);
  }

  String methodFor(Map<String, dynamic> withdrawal) {
    final direct = _firstNonEmpty([
      withdrawal['methodResolved'],
      withdrawal['method'],
      withdrawal['paymentMethod'],
      withdrawal['payment_method'],
      withdrawal['type'],
      withdrawal['channel'],
      withdrawal['provider'],
    ]);
    return direct;
  }

  String ibanFor(Map<String, dynamic> withdrawal) {
    final direct = _firstNonEmpty([
      withdrawal['ibanResolved'],
      withdrawal['iban'],
      withdrawal['bankIban'],
      withdrawal['accountIban'],
      withdrawal['bank'] is Map<String, dynamic>
          ? (withdrawal['bank'] as Map<String, dynamic>)['iban']
          : null,
      withdrawal['bankAccount'] is Map<String, dynamic>
          ? (withdrawal['bankAccount'] as Map<String, dynamic>)['iban']
          : null,
    ]);
    return direct;
  }

  List<Map<String, dynamic>> _normalizeWithdrawals(dynamic data) {
    final payload = _unwrapData(data);
    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((e) => _normalizeWithdrawal(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (payload is Map<String, dynamic>) {
      final list = payload['withdrawals'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => _normalizeWithdrawal(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [_normalizeWithdrawal(payload)];
    }
    return <Map<String, dynamic>>[];
  }

  dynamic _unwrapData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return data;
  }

  Map<String, dynamic> _normalizeWithdrawal(Map<String, dynamic> raw) {
    final id = _extractIdFromAny(raw['id'] ?? raw['_id']);
    final artisanId = _extractIdFromAny(
      raw['artisanId'] ?? raw['artisan'] ?? raw['artisan_id'],
    );
    final artisanName = _extractName(
      raw['artisan'] ??
          raw['artisanName'] ??
          raw['artisan_name'] ??
          raw['user'] ??
          raw['owner'],
    );
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

  Future<void> _hydrateArtisanNames(List<Map<String, dynamic>> list) async {
    artisanNamesById.clear();
    if (list.isEmpty) return;

    final missingIds = <String>{};
    for (final item in list) {
      final name = artisanNameFor(item);
      if (name.isNotEmpty) continue;
      final artisanId = _extractIdFromAny(item['artisanId'] ?? item['artisan']);
      if (artisanId.isNotEmpty) {
        missingIds.add(artisanId);
      }
    }
    if (missingIds.isEmpty) return;

    try {
      final artisans = await _service.fetchArtisans();
      final map = <String, String>{};
      for (final raw in artisans) {
        final artisan = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final id = _extractIdFromAny(artisan['_id'] ?? artisan['id']);
        if (id.isEmpty || !missingIds.contains(id)) continue;
        final name = _extractName(artisan);
        if (name.isNotEmpty) map[id] = name;
      }
      if (map.isEmpty) return;
      artisanNamesById.assignAll(map);

      final enriched = withdrawals.map((raw) {
        final item = raw is Map<String, dynamic>
            ? Map<String, dynamic>.from(raw)
            : <String, dynamic>{};
        final existingName = _sanitizeName(
          (item['artisanName'] ?? '').toString(),
        );
        if (existingName.isNotEmpty) return item;
        final artisanId = _extractIdFromAny(
          item['artisanId'] ?? item['artisan'],
        );
        final name = map[artisanId];
        if (name != null && name.trim().isNotEmpty) {
          item['artisanName'] = name;
        }
        return item;
      }).toList();
      withdrawals.assignAll(enriched);
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

  String _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      final text = v?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
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
