import 'package:get/get.dart';

import '../constants/app_colors.dart';

void showError(String message) {
  Get.snackbar(
    'Error'.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.card,
    colorText: AppColors.text,
  );
}

void showSuccess(String message) {
  Get.snackbar(
    'Success'.tr,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.card,
    colorText: AppColors.text,
  );
}
