import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../../../core/constants/app_config.dart';
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
      form['about']?.value = (payload['about'] ?? '').toString();
      final logo = (payload['logoUrl'] ?? '').toString();
      form['logoUrl']?.value = _normalizedUrl(logo);
    } catch (e) {
      error.value = e is ApiException ? e.message : e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> save() async {
    saving.value = true;
    try {
      final logoValue = form['logoUrl']?.value ?? '';
      final apiLogo = logoValue.startsWith(AppConfig.baseUrl)
          ? logoValue.replaceFirst(AppConfig.baseUrl, '')
          : logoValue;
      await _service.updateGeneral({
        'appName': form['appName']?.value,
        'supportEmail': form['supportEmail']?.value,
        'about': form['about']?.value,
        'logoUrl': apiLogo,
      });
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

  Future<void> uploadLogo({
    required String fileName,
    List<int>? bytes,
    String? path,
  }) async {
    uploadingLogo.value = true;
    try {
      if (bytes == null && path == null) {
        throw ApiException('No file selected');
      }
      final file = bytes != null
          ? MultipartFile.fromBytes(bytes, filename: fileName)
          : await MultipartFile.fromFile(path!, filename: fileName);
      final formData = FormData.fromMap({'logo': file});
      final res = await _service.uploadLogo(formData);
      final data = res.data;
      final url = data is Map<String, dynamic> ? (data['data']?['url'] ?? data['url']) : null;
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
