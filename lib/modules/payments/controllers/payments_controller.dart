import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payments_service.dart';

class PaymentsController extends GetxController {
  final PaymentsService _service;
  PaymentsController({PaymentsService? service})
    : _service = service ?? PaymentsService();

  final transactions = <Map<String, dynamic>>[].obs;
  final userNamesByPaymentId = <String, String>{}.obs;
  final loading = false.obs;
  final error = RxnString();
  final filter = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  Future<void> loadTransactions({
    Map<String, dynamic>? params,
    bool reset = false,
  }) async {
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
      final res = query == null
          ? await _service.transactions()
          : await _service.filter(query);
      final data = res.data;
      final normalized = _normalizeList(_unwrapData(data));
      transactions.assignAll(normalized);
      await _hydrateUserNames(normalized);
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

  Future<void> _hydrateUserNames(List<Map<String, dynamic>> list) async {
    userNamesByPaymentId.clear();
    if (list.isEmpty) return;

    final requestToPayments = <String, List<String>>{};
    final artisanToPayments = <String, List<String>>{};

    for (final payment in list) {
      final paymentId = _extractId(payment);
      if (paymentId.isEmpty) continue;

      final direct = _extractName(
        payment['customer'] ??
            payment['customerId'] ??
            payment['user'] ??
            payment['client'],
        fallback:
            payment['customerName'] ??
            payment['userName'] ??
            payment['username'] ??
            payment['clientName'],
      );
      if (direct.isNotEmpty) {
        userNamesByPaymentId[paymentId] = direct;
        continue;
      }

      final requestId = _extractIdFromAny(payment['requestId']);
      if (requestId.isNotEmpty) {
        requestToPayments
            .putIfAbsent(requestId, () => <String>[])
            .add(paymentId);
      }

      final artisanId = _extractIdFromAny(
        payment['artisanId'] ?? payment['artisan'],
      );
      if (artisanId.isNotEmpty) {
        artisanToPayments
            .putIfAbsent(artisanId, () => <String>[])
            .add(paymentId);
      }
    }

    if (requestToPayments.isNotEmpty) {
      try {
        final requests = await _service.fetchRequests();
        final requestToCustomerName = <String, String>{};
        for (final raw in requests) {
          final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
          final reqId = _extractIdFromAny(
            req['_id'] ?? req['id'] ?? req['requestId'],
          );
          if (reqId.isEmpty) continue;

          final customerName = _extractName(
            req['customer'] ??
                req['customerId'] ??
                req['client'] ??
                req['user'],
            fallback:
                req['customerName'] ??
                req['userName'] ??
                req['username'] ??
                req['clientName'],
          );
          if (customerName.isNotEmpty) {
            requestToCustomerName[reqId] = customerName;
          }
        }

        for (final entry in requestToPayments.entries) {
          final customerName = requestToCustomerName[entry.key];
          if (customerName == null || customerName.trim().isEmpty) continue;
          for (final paymentId in entry.value) {
            userNamesByPaymentId[paymentId] = customerName;
          }
        }
      } catch (_) {
        // Keep silent fallback if requests endpoint fails.
      }
    }

    final unresolvedArtisanToPayments = <String, List<String>>{};
    for (final entry in artisanToPayments.entries) {
      final pendingPaymentIds = entry.value
          .where(
            (paymentId) =>
                !(userNamesByPaymentId[paymentId]?.trim().isNotEmpty ?? false),
          )
          .toList();
      if (pendingPaymentIds.isNotEmpty) {
        unresolvedArtisanToPayments[entry.key] = pendingPaymentIds;
      }
    }

    if (unresolvedArtisanToPayments.isNotEmpty) {
      try {
        final artisans = await _service.fetchArtisans();
        final artisanNameMap = <String, String>{};
        for (final raw in artisans) {
          final artisan = raw is Map<String, dynamic>
              ? raw
              : <String, dynamic>{};
          final id = _extractIdFromAny(artisan['_id'] ?? artisan['id']);
          if (id.isEmpty) continue;

          final name = _extractName(
            artisan,
            fallback: artisan['userName'] ?? artisan['username'],
          );
          if (name.isNotEmpty) {
            artisanNameMap[id] = name;
          }
        }

        for (final entry in unresolvedArtisanToPayments.entries) {
          final artisanName = artisanNameMap[entry.key];
          if (artisanName == null || artisanName.trim().isEmpty) continue;
          for (final paymentId in entry.value) {
            userNamesByPaymentId[paymentId] = artisanName;
          }
        }
      } catch (_) {
        // Keep silent fallback if artisans endpoint fails.
      }
    }
  }

  String userNameFor(Map<String, dynamic> payment) {
    final paymentId = _extractId(payment);
    final mappedNameRaw = paymentId.isEmpty
        ? ''
        : (userNamesByPaymentId[paymentId] ?? '');
    final mappedName = _sanitizeName(mappedNameRaw);
    if (mappedName.trim().isNotEmpty) return mappedName;

    final direct = _extractName(
      payment['customer'] ??
          payment['customerId'] ??
          payment['user'] ??
          payment['client'] ??
          payment['artisan'] ??
          payment['artisanId'],
      fallback:
          payment['customerName'] ??
          payment['userName'] ??
          payment['username'] ??
          payment['clientName'],
    );
    if (direct.trim().isNotEmpty) return direct;

    return '';
  }

  String methodFor(Map<String, dynamic> payment) {
    final methodKeys = const [
      'method',
      'paymentMethod',
      'payment_method',
      'methodName',
      'methodType',
      'type',
      'channel',
      'gateway',
      'provider',
      'source',
    ];

    final direct = _methodTextFrom(payment, keys: methodKeys);
    if (direct.isNotEmpty) return direct;

    final nested =
        payment['payment'] ??
        payment['details'] ??
        payment['meta'] ??
        payment['data'];
    return _methodTextFrom(nested, keys: methodKeys);
  }

  String _extractId(Map<String, dynamic> payment) {
    return _extractIdFromAny(payment['_id'] ?? payment['id']);
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

  String _extractName(dynamic value, {dynamic fallback}) {
    final fromValue = _stringFrom(value);
    if (fromValue.isNotEmpty) return fromValue;
    return _stringFrom(fallback);
  }

  String _stringFrom(dynamic value) {
    if (value == null) return '';
    if (value is String) return _sanitizeName(value);
    if (value is num) return value.toString();
    if (value is Map<String, dynamic>) {
      final direct =
          value['name'] ??
          value['fullName'] ??
          value['displayName'] ??
          value['userName'] ??
          value['username'] ??
          value['email'] ??
          value['phone'];
      final name = _sanitizeName(direct?.toString() ?? '');
      if (name.isNotEmpty) {
        return name;
      }
    }
    return '';
  }

  String _sanitizeName(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (_looksLikeObjectId(value)) return '';
    return value;
  }

  bool _looksLikeObjectId(String value) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  String _methodTextFrom(dynamic value, {required List<String> keys}) {
    if (value == null) return '';
    if (value is String || value is num) return value.toString().trim();
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final raw = value[key];
        if (raw == null) continue;
        final text = raw.toString().trim();
        if (text.isNotEmpty) return text;
      }
    }
    return '';
  }

  Future<void> applyFilter(Map<String, dynamic> params) async {
    await loadTransactions(params: params);
  }

  Future<void> clearFilter() async {
    await loadTransactions(reset: true);
  }
}
