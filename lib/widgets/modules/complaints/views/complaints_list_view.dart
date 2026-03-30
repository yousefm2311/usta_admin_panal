import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/complaints_controller.dart';

class ComplaintsListView extends StatelessWidget {
  const ComplaintsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplaintsController());
    final statuses = ['All', 'open', 'assigned', 'resolved', 'closed'];
    return AdminLayout(
      title: ''.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Complaints'.tr,
                style:  TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Obx(
                () => DropdownButton<String>(
                  value: controller.status.value.isEmpty
                      ? 'All'
                      : controller.status.value,
                  dropdownColor: AppColors.card,
                  items: statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.tr)))
                      .toList(),
                  onChanged: (v) =>
                      controller.setStatus(v == 'All' ? '' : v ?? ''),
                ),
              ),
              IconButton(
                onPressed: controller.loadComplaints,
                icon:  Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const ListLoading(itemHeight: 40,);
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  controller.error.value!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }
            if (controller.complaints.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'No data'.tr,
                  style:  TextStyle(color: AppColors.textMuted),
                ),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Artisan'.tr)),
                  DataColumn(label: Text('Customers'.tr)),
                  DataColumn(label: Text('Issue'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.complaints
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(
                            Text(('${c['artisan']?['name'] ?? ''}').toString()),
                          ),
                          DataCell(
                            Text(
                              ('${c['customer']?['name'] ?? ''}').toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              trimWords(
                                (c['issue'] ?? c['title'] ?? '').toString(),
                                words: 3,
                              ),
                            ),
                          ),

                          DataCell(
                            _statusChip((c['status'] ?? '').toString()),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () => Get.toNamed(
                                '/complaint/details',
                                arguments: c,
                              ),
                              child: Text('View details'.tr),
                            ),
                          ),
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

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'closed':
        color = AppColors.danger;
        break;
      case 'assigned':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String trimWords(String text, {int words = 3}) {
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length <= words) return text;
    return '${parts.take(words).join(' ')}...';
  }
}
