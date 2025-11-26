import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class NotificationTemplatesView extends StatelessWidget {
  const NotificationTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Notification Templates'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Templates'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name'.tr)),
                DataColumn(label: Text('Target'.tr)),
                DataColumn(label: Text('Updated'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: List.generate(
                5,
                (i) => DataRow(
                  cells: const [
                    DataCell(Text('Payment reminder')),
                    DataCell(Text('Customers')),
                    DataCell(Text('Oct 22')),
                    DataCell(Text('Edit')),
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
