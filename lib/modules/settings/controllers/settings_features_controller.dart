import 'dart:convert';

import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/settings_service.dart';

class SettingsFeaturesController extends GetxController {
  final SettingsService _service;
  SettingsFeaturesController({SettingsService? service}) : _service = service ?? SettingsService();

  final saving = false.obs;
  final error = RxnString();

  Future<void> save(String rawJson) async {
    final trimmed = rawJson.trim();
    if (trimmed.isEmpty) {
      const msg = 'Please enter a JSON payload';
      error.value = msg;
      showError(msg.tr);
      return;
    }

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      } else if (decoded is Map) {
        payload = Map<String, dynamic>.from(decoded);
      } else {
        throw const FormatException('JSON must be an object');
      }
    } catch (_) {
      const msg = 'Invalid JSON payload';
      error.value = msg;
      showError(msg.tr);
      return;
    }

    saving.value = true;
    error.value = null;
    try {
      await _service.updateFeatures(payload);
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }
}
