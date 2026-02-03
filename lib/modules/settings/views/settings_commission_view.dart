import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/settings_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class SettingsCommissionView extends StatelessWidget {
  const SettingsCommissionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return AdminLayout(
      title: 'Commission',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 200, lines: 4);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commission settings'.tr,
              style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSizes.md),
            Container(
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Commission percentage'.tr, style:  TextStyle(color: AppColors.text)),
                      const Spacer(),
                      Text('${controller.commission.value.toStringAsFixed(0)}%',
                          style:  TextStyle(color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: controller.commission.value,
                    min: 0,
                    max: 30,
                    divisions: 30,
                    label: '${controller.commission.value.toStringAsFixed(0)}%',
                    activeColor: AppColors.primary,
                    onChanged: (value) => controller.commission.value = value,
                    onChangeEnd: (_) => controller.saveCommission(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'This slider updates the service commission applied to every completed request.'.tr,
                    style:  TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}


