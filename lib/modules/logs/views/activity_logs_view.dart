import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class ActivityLogsView extends StatelessWidget {
  const ActivityLogsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Activity Logs'.tr,
      child: Column(
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
              rows: List.generate(
                6,
                (i) => const DataRow(
                  cells: [
                    DataCell(Text('Admin')),
                    DataCell(Text('Updated settings')),
                    DataCell(Text('Settings')),
                    DataCell(Text('12:20 PM')),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
