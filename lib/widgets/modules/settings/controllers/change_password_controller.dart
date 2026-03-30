import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../../auth/services/auth_service.dart';

class ChangePasswordController extends GetxController {
  final AuthService _service;
  ChangePasswordController({AuthService? service}) : _service = service ?? AuthService();

  final saving = false.obs;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    saving.value = true;
    try {
      await _service.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      showSuccess('Success'.tr);
      return true;
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
      return false;
    } finally {
      saving.value = false;
    }
  }
}
