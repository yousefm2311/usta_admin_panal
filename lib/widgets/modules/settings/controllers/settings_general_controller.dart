import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../../../../core/constants/app_config.dart';
import '../services/settings_service.dart';

class SettingsGeneralController extends GetxController {
  final SettingsService _service;
  SettingsGeneralController({SettingsService? service}) : _service = service ?? SettingsService();

  final form = {
    'appName': ''.obs,
    'supportEmail': ''.obs,
    'about': ''.obs,
    'logoUrl': ''.obs,
  };
  final loading = false.obs;
  final saving = false.obs;
  final uploadingLogo = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadGeneral();
  }

  Future<void> loadGeneral() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.getGeneral();
      final data = res.data;
      final payload = data is Map<String, dynamic> ? (data['data'] ?? data) : {};
      form['appName']?.value = (payload['appName'] ?? '').toString();
      form['supportEmail']?.value = (payload['supportEmail'] ?? '').toString();
      final logo = (payload['logoUrl'] ?? '').toString();
      form['logoUrl']?.value = _normalizedUrl(logo);
      try {
        final aboutRes = await _service.getAbout();
        final aboutData = aboutRes.data;
        final aboutPayload = aboutData is Map<String, dynamic> ? (aboutData['data'] ?? aboutData) : {};
        form['about']?.value = (aboutPayload['about'] ?? '').toString();
      } catch (_) {
        // About is optional; keep existing value if request fails.
      }
    } catch (e) {
      error.value = e is ApiException ? e.message : e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> save() async {
    saving.value = true;
    try {
      final appName = form['appName']?.value.trim();
      final supportEmail = form['supportEmail']?.value.trim();
      final payload = <String, dynamic>{
        if (appName != null && appName.isNotEmpty) 'appName': appName,
        if (supportEmail != null && supportEmail.isNotEmpty) 'supportEmail': supportEmail,
      };
      if (payload.isNotEmpty) {
        await _service.updateGeneral(payload);
      }
      final about = form['about']?.value.trim();
      if (about != null && about.isNotEmpty) {
        await _service.updateAbout(about);
      }
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

Future<void> uploadLogo({
    required String fileName,
    required List<int> bytes, // نخليها required ونشيل path
  }) async {
    uploadingLogo.value = true;

    try {
      final file = MultipartFile.fromBytes(bytes, filename: fileName);
      final formData = FormData.fromMap({'logo': file});
      final res = await _service.uploadLogo(formData);
      final data = res.data;
      final url = data is Map<String, dynamic>
          ? (data['data']?['url'] ?? data['url'])
          : null;

      if (url != null) {
        form['logoUrl']?.value = _normalizedUrl(url.toString());
        showSuccess('Success'.tr);
      }
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      uploadingLogo.value = false;
    }
  }


  String _normalizedUrl(String value) {
    if (value.isEmpty) return '';
    if (value.startsWith('http')) return value;
    // ensure we always have absolute URL for images
    return value.startsWith('/')
        ? '${AppConfig.baseUrl}$value'
        : '${AppConfig.baseUrl}/$value';
  }
}
