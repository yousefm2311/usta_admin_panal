import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class ComplaintsListView extends StatelessWidget {
  const ComplaintsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Complaints'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Complaints'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('ID'.tr)),
                DataColumn(label: Text('Customer'.tr)),
                DataColumn(label: Text('Issue'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: List.generate(
                5,
                (i) => DataRow(
                  cells: [
                    DataCell(Text('#C$i')),
                    DataCell(Text('Customer'.tr)),
                    DataCell(Text('Issue'.tr)),
                    DataCell(Text('Open'.tr)),
                    DataCell(TextButton(onPressed: () {}, child: Text('View details'.tr))),
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
