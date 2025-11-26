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
              Text('Rewards'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              if (data != null) ...[
                Row(
                  children: [
                    _pill('Points'.tr, (data['points'] ?? data['totalPoints'] ?? '0').toString()),
                    const SizedBox(width: AppSizes.sm),
                    _pill('Levels'.tr, (data['levels'] is List ? (data['levels'] as List).length : '0').toString()),
                  ],
                ),
                const SizedBox(height: AppSizes.md),
                if (data['levels'] is List && (data['levels'] as List).isNotEmpty) ...[
                  Text('Levels'.tr, style: const TextStyle(color: AppColors.text)),
                  const SizedBox(height: AppSizes.xs),
                  ...(data['levels'] as List)
                      .map<Widget>(
                        (lvl) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.xs),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text((lvl['name'] ?? '').toString(),
                                    style: const TextStyle(color: AppColors.text)),
                              ),
                              Text((lvl['threshold'] ?? lvl['points'] ?? '').toString(),
                                  style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
                const SizedBox(height: AppSizes.sm),
                if (data['history'] is List && (data['history'] as List).isNotEmpty) ...[
                  Text('Redeem history'.tr, style: const TextStyle(color: AppColors.text)),
                  const SizedBox(height: AppSizes.xs),
                  ...(data['history'] as List)
                      .map<Widget>(
                        (h) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.xs),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text((h['title'] ?? h['reward'] ?? '').toString(),
                                    style: const TextStyle(color: AppColors.text)),
                              ),
                              Text((h['points'] ?? h['amount'] ?? '').toString(),
                                  style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ] else ...[
                Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
