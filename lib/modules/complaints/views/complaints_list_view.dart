import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/complaints_controller.dart';

class ComplaintsListView extends StatelessWidget {
  const ComplaintsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintsController());
    final statuses = ['All', 'open', 'assigned', 'resolved', 'closed'];
    return AdminLayout(
      title: 'Complaints'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Complaints'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Obx(
                () => DropdownButton<String>(
                  value: controller.status.value.isEmpty ? 'All' : controller.status.value,
                  dropdownColor: AppColors.card,
                  items: statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.tr)))
                      .toList(),
                  onChanged: (v) => controller.setStatus(v == 'All' ? '' : v ?? ''),
                ),
              ),
              IconButton(
                onPressed: controller.loadComplaints,
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
            if (controller.complaints.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID'.tr)),
                  DataColumn(label: Text('Customer'.tr)),
                  DataColumn(label: Text('Issue'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.complaints
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text((c['_id'] ?? '').toString())),
                          DataCell(Text((c['customer'] ?? c['customerName'] ?? '').toString())),
                          DataCell(Text((c['issue'] ?? c['title'] ?? '').toString())),
                          DataCell(Text((c['status'] ?? '').toString())),
                          DataCell(TextButton(
                            onPressed: () => Get.toNamed('/complaint/details', arguments: c),
                            child: Text('View details'.tr),
                          )),
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
