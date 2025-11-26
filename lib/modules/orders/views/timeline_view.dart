import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/order_details_controller.dart';
import '../../../core/utils/notify.dart';

class OrderTimelineView extends StatelessWidget {
  const OrderTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(OrderDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: 'Timeline'.tr,
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
        final steps = controller.timeline;
        if (steps.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        final status = 'pending'.obs;
        final noteCtrl = TextEditingController();
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
              Text('Timeline'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSizes.md),
              ...steps.asMap().entries.map(
                (e) => Row(
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: const Icon(Icons.check, color: AppColors.primary),
                        ),
                        if (e.key != steps.length - 1)
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.border,
                          ),
                      ],
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((e.value['status'] ?? '').toString().tr,
                              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            (e.value['note'] ?? e.value['createdAt'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Obx(
                      () => DropdownButton<String>(
                        value: status.value,
                        dropdownColor: AppColors.card,
                        items: ['pending', 'accepted', 'in_progress', 'completed', 'canceled', 'closed']
                            .map((s) => DropdownMenuItem(value: s, child: Text(s.tr)))
                            .toList(),
                        onChanged: (v) => status.value = v ?? status.value,
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: noteCtrl,
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(hintText: 'Note'.tr),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => controller.addTimeline(id, status: status.value, note: noteCtrl.text),
                      icon: const Icon(Icons.add),
                      label: Text('Add'.tr),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.text,
                      ),
                      onPressed: () => controller.load(id),
                      icon: const Icon(Icons.refresh),
                      label: Text('Refresh'.tr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
