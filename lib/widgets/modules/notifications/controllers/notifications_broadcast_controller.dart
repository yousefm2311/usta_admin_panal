import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/notifications_service.dart';

class NotificationsBroadcastController extends GetxController {
  final NotificationsService _service;
  NotificationsBroadcastController({NotificationsService? service}) : _service = service ?? NotificationsService();

  final sending = false.obs;

  Future<void> broadcast({
    required String audience,
    required String title,
    required String body,
    String? topic,
    List<String>? customerIds,
    List<String>? artisanIds,
    List<String>? adminIds,
  }) async {
    sending.value = true;
    try {
      final payload = <String, dynamic>{
        'audience': audience,
        'title': title,
        'body': body,
      };
      if (topic != null && topic.trim().isNotEmpty) {
        payload['topic'] = topic.trim();
      }
      if (customerIds != null && customerIds.isNotEmpty) {
        payload['customerIds'] = customerIds;
      }
      if (artisanIds != null && artisanIds.isNotEmpty) {
        payload['artisanIds'] = artisanIds;
      }
      if (adminIds != null && adminIds.isNotEmpty) {
        payload['adminIds'] = adminIds;
      }

      await _service.broadcast(payload);
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      sending.value = false;
    }
  }
}
