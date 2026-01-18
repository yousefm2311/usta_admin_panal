import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/notifications_service.dart';

class NotificationsTokensController extends GetxController {
  final NotificationsService _service;
  NotificationsTokensController({NotificationsService? service}) : _service = service ?? NotificationsService();

  final tokens = <dynamic>[].obs;
  final loading = false.obs;
  final actioning = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTokens();
  }

  Future<void> loadTokens() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.listFcmTokens();
      final data = res.data;
      if (data is List) {
        tokens.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        tokens.assignAll(data['tokens'] ?? data['data'] ?? []);
      } else {
        tokens.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> subscribe({required String topic, String? deviceId}) async {
    await _topicAction(
      () => _service.subscribeTopic(_buildTopicPayload(topic, deviceId: deviceId)),
    );
  }

  Future<void> unsubscribe({required String topic, String? deviceId}) async {
    await _topicAction(
      () => _service.unsubscribeTopic(_buildTopicPayload(topic, deviceId: deviceId)),
    );
  }

  Map<String, dynamic> _buildTopicPayload(String topic, {String? deviceId}) {
    final payload = <String, dynamic>{'topic': topic.trim()};
    if (deviceId != null && deviceId.trim().isNotEmpty) {
      payload['deviceId'] = deviceId.trim();
    }
    return payload;
  }

  Future<void> _topicAction(Future<dynamic> Function() action) async {
    actioning.value = true;
    try {
      await action();
      showSuccess('Success'.tr);
      await loadTokens();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      actioning.value = false;
    }
  }
}
