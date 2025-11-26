import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/activity_logs_controller.dart';

class ActivityLogsView extends StatelessWidget {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityLogsController());
    return AdminLayout(
      title: 'Activity Logs'.tr,
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
        if (controller.logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity logs'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.md),
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('User'.tr)),
                  DataColumn(label: Text('Action'.tr)),
                  DataColumn(label: Text('Module'.tr)),
                  DataColumn(label: Text('Time'.tr)),
                ],
                rows: controller.logs
                    .map(
                      (l) => DataRow(
                        cells: [
                          DataCell(Text((l['actor'] ?? '').toString())),
                          DataCell(Text((l['action'] ?? '').toString())),
                          DataCell(Text((l['entity'] ?? '').toString())),
                          DataCell(Text((l['createdAt'] ?? '').toString())),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
