import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/notifications_controller.dart';

class NotificationsCenterView extends StatelessWidget {
  const NotificationsCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return AdminLayout(
      title: 'Notifications',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Sent notifications'.tr,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadHistory,
                icon: const Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
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
            if (controller.history.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return Column(
              children: controller.history
                  .map(
                    (n) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_none, color: AppColors.primary),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (n['title'] ?? '').toString(),
                                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  (n['target'] ?? '').toString().tr,
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatDate(n['date'] ?? n['createdAt']),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }
}
