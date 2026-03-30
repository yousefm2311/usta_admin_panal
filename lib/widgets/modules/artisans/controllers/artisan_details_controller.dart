import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/artisans_service.dart';

class ArtisanDetailsController extends GetxController {
  final ArtisansService _service;
  ArtisanDetailsController({ArtisansService? service}) : _service = service ?? ArtisansService();

  final artisan = Rxn<Map<String, dynamic>>();
  final verification = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final verificationLoading = false.obs;
  final actionLoading = false.obs;
  final error = RxnString();
  String? _lastLoadedId;

  Future<void> load(String id, {bool force = false}) async {
    if (!force && _lastLoadedId == id) {
      if (loading.value || artisan.value != null) {
        return;
      }
    }
    _lastLoadedId = id;
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchDetails(id);
      final data = res.data;
      artisan.value = data is Map<String, dynamic> ? (data['artisan'] ?? data['data'] ?? data) : null;
      await _loadVerification(id);
      _loadDerivedStats(id);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadVerification(String artisanId) async {
    verificationLoading.value = true;
    try {
      final res = await _service.fetchVerification(artisanId);
      final data = res.data;
      final payload = data is Map<String, dynamic>
          ? (data['data'] ?? data)
          : null;
      if (payload is Map<String, dynamic>) {
        final verificationPayload = payload['verification'];
        verification.value = verificationPayload is Map<String, dynamic>
            ? verificationPayload
            : verificationPayload is Map
                ? Map<String, dynamic>.from(verificationPayload)
                : null;
      }
    } catch (_) {
      verification.value = null;
    } finally {
      verificationLoading.value = false;
    }
  }

  Future<void> _loadDerivedStats(String artisanId) async {
    if (artisanId.isEmpty) return;
    try {
      final results = await Future.wait<List<dynamic>>([
        _service.fetchRequests(),
        _service.fetchReviews(),
      ]);
      final requests = results[0];
      final reviews = results[1];
      final computed = _computeStats(artisanId, requests, reviews);
      final customers = _extractCustomers(artisanId, requests);
      if (computed.isEmpty) return;
      final current = artisan.value;
      if (current == null) return;
      final existingStatsRaw = current['stats'];
      final existingStats = existingStatsRaw is Map<String, dynamic>
          ? Map<String, dynamic>.from(existingStatsRaw)
          : existingStatsRaw is Map
          ? Map<String, dynamic>.from(existingStatsRaw)
          : <String, dynamic>{};
      existingStats.addAll(computed);
      artisan.value = {...current, 'stats': existingStats};
      if (customers.isNotEmpty) {
        artisan.value = {
          ...artisan.value!,
          'customersPreview': customers,
        };
      }
    } catch (_) {
      // Keep existing stats if extra endpoints are unavailable.
    }
  }

  Map<String, dynamic> _computeStats(
    String artisanId,
    List<dynamic> requests,
    List<dynamic> reviews,
  ) {
    final normalizedId = artisanId.toString();
    int completed = 0;
    int active = 0;
    double totalTicket = 0;
    int ticketCount = 0;

    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final reqArtisanId =
          (req['artisanId']?['_id'] ?? req['artisanId'] ?? req['artisan']?['_id'] ?? req['artisan'])
              ?.toString() ??
          '';
      if (reqArtisanId != normalizedId) continue;

      final status = (req['status'] ?? '').toString().toLowerCase();
      final isCompleted = status == 'completed' || status == 'closed';
      final isTerminal =
          isCompleted ||
          status == 'cancelled' ||
          status == 'canceled' ||
          status == 'rejected' ||
          status == 'expired';
      if (isCompleted) {
        completed += 1;
      } else if (!isTerminal && status.isNotEmpty) {
        active += 1;
      }

      final priceCandidate =
          req['agreedPrice'] ??
          req['price'] ??
          req['amount'] ??
          req['total'] ??
          req['pricing']?['proposedPrice'];
      final price = double.tryParse(priceCandidate?.toString() ?? '');
      if (price != null && price > 0) {
        totalTicket += price;
        ticketCount += 1;
      }
    }

    double totalRating = 0;
    int ratingCount = 0;
    for (final raw in reviews) {
      final review = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final reviewArtisanId =
          (review['artisanId']?['_id'] ?? review['artisanId'] ?? review['artisan']?['_id'] ?? review['artisan'])
              ?.toString() ??
          '';
      if (reviewArtisanId != normalizedId) continue;
      final rating = double.tryParse((review['rating'] ?? 0).toString()) ?? 0;
      if (rating > 0) {
        totalRating += rating;
        ratingCount += 1;
      }
    }

    final avgTicket = ticketCount > 0 ? totalTicket / ticketCount : 0;
    final avgRating = ratingCount > 0 ? totalRating / ratingCount : 0;

    return {
      'completed': completed,
      'active': active,
      'avgTicket': avgTicket,
      'rating': avgRating,
    };
  }

  List<Map<String, dynamic>> _extractCustomers(
    String artisanId,
    List<dynamic> requests,
  ) {
    final normalizedId = artisanId.toString();
    final seen = <String, Map<String, dynamic>>{};
    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final reqArtisanId =
          (req['artisanId']?['_id'] ?? req['artisanId'] ?? req['artisan']?['_id'] ?? req['artisan'])
              ?.toString() ??
          '';
      if (reqArtisanId != normalizedId) continue;
      final customer = req['customerId'] ?? req['customer'];
      if (customer is Map<String, dynamic>) {
        final id = (customer['_id'] ?? customer['id'] ?? '').toString();
        if (id.isEmpty) continue;
        seen[id] = {
          'id': id,
          'name': customer['name'] ?? '',
          'phone': customer['phone'] ?? '',
          'email': customer['email'] ?? '',
        };
      }
    }
    return seen.values.take(10).toList();
  }

  Future<void> approve(String id) async {
    try {
      await _service.approve(id);
      showSuccess('Success'.tr);
      await load(id, force: true);
      _setLocalStatus('Approved');
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> reject(String id) async {
    try {
      await _service.reject(id);
      showSuccess('Success'.tr);
      await load(id, force: true);
      _setLocalStatus('Rejected');
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> setSuspended(String id, {required bool suspended}) async {
    try {
      await _service.updateStatus(id, suspended: suspended);
      showSuccess('Success'.tr);
      await load(id, force: true);
      _setLocalStatus(artisan.value?['status']?.toString() ?? 'Approved', suspended: suspended);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> approveKyc(String id) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      await _service.approveVerification(id);
      showSuccess('Success'.tr);
      await load(id, force: true);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      actionLoading.value = false;
    }
  }

  Future<void> rejectKyc(
    String id, {
    String? rejectionCategory,
    String? rejectionReasonUserSafe,
    String? rejectionReasonInternal,
  }) async {
    if (actionLoading.value) return;
    actionLoading.value = true;
    try {
      await _service.rejectVerification(
        id,
        rejectionCategory: rejectionCategory,
        rejectionReasonUserSafe: rejectionReasonUserSafe,
        rejectionReasonInternal: rejectionReasonInternal,
      );
      showSuccess('Success'.tr);
      await load(id, force: true);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      actionLoading.value = false;
    }
  }

  bool get canReviewKyc {
    final status = (verification.value?['verificationStatus'] ?? '')
        .toString()
        .toLowerCase();
    return status == 'under_review' ||
        status == 'selfie_uploaded' ||
        status == 'documents_uploaded' ||
        status == 'rejected';
  }

  String verificationImageUrl(String id, String type) =>
      _service.verificationImageUrl(id, type);

  void _setLocalStatus(String status, {bool? suspended}) {
    final current = artisan.value;
    if (current == null) {
      return;
    }
    final normalized = status.toLowerCase();
    artisan.value = {
      ...current,
      'status': status,
      'approved': normalized == 'approved' || normalized == 'active',
      'rejected': normalized == 'rejected',
      if (suspended != null) 'suspended': suspended,
    };
  }
}
