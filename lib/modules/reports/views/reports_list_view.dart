import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/formate_date.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/reports_controller.dart';

class ReportsListView extends StatelessWidget {
  const ReportsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    final statuses = ['All', 'Open', 'In review', 'Closed'];

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports'.tr,
            style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Wrap(
                spacing: AppSizes.sm,
                children: statuses
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status.tr),
                        selected: controller.filter.value == status,
                        onSelected: (_) => controller.changeFilter(status),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: controller.filter.value == status ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 8);
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            if (controller.reports.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Reporter'.tr)),
                  DataColumn(label: Text('Subject'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.reports
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(Text(_reporterName(r))),
                          DataCell(Text(_subject(r))),
                          DataCell(_statusChip((r['status'] ?? '').toString())),
                          DataCell(Text(formatDateString(r['createdAt'] ?? r['date']))),
                          DataCell(
                            TextButton(
                              onPressed: () => Get.toNamed('/report/details', arguments: r),
                              child: Text('View details'.tr),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                headingTextStyle:  TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle:  TextStyle(color: AppColors.text),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _reporterName(Map<String, dynamic> r) {
    final reporter = r['reporter'] ?? r['customer'] ?? r['user'] ?? r['owner'];
    if (reporter is Map<String, dynamic>) {
      return (reporter['name'] ?? reporter['fullName'] ?? reporter['email'] ?? '').toString();
    }
    return (r['reporterName'] ?? r['customerName'] ?? '').toString();
  }

  String _subject(Map<String, dynamic> r) {
    return (r['subject'] ?? r['title'] ?? r['issue'] ?? r['reason'] ?? '').toString();
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        color = AppColors.warning;
        break;
      case 'in_review':
      case 'in review':
        color = Colors.amber;
        break;
      case 'closed':
        color = AppColors.textMuted;
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
