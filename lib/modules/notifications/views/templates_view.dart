import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/notifications_controller.dart';

class NotificationTemplatesView extends StatelessWidget {
  const NotificationTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    return AdminLayout(
      title: 'Notification Templates'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Templates'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.templates.isEmpty && controller.loading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (controller.templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name'.tr)),
                  DataColumn(label: Text('Target'.tr)),
                  DataColumn(label: Text('Updated'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.templates
                    .map(
                      (t) => DataRow(
                        cells: [
                          DataCell(Text((t['name'] ?? '').toString())),
                          DataCell(Text((t['target'] ?? '').toString())),
                          DataCell(Text((t['updatedAt'] ?? '').toString())),
                          const DataCell(Text('Edit')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}
