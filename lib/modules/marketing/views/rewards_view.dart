import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/rewards_controller.dart';

class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RewardsController());
    return AdminLayout(
      title: 'Rewards'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final data = controller.data.value;
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rewards levels & points placeholder'.tr, style: const TextStyle(color: AppColors.text)),
              const SizedBox(height: AppSizes.sm),
              Text((data?['summary'] ?? '').toString(), style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: AppSizes.sm),
              Text('Redeem history list'.tr, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        );
      }),
    );
  }
}
