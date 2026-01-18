import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/artisans_service.dart';

class ArtisanDetailsController extends GetxController {
  final ArtisansService _service;
  ArtisanDetailsController({ArtisansService? service}) : _service = service ?? ArtisansService();

  final artisan = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
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
