import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class RolesListView extends StatelessWidget {
  const RolesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Roles'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Roles & Permissions'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Role'.tr)),
                DataColumn(label: Text('Modules'.tr)),
                DataColumn(label: Text('Members'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: List.generate(
                4,
                (i) => const DataRow(
                  cells: [
                    DataCell(Text('Admin')),
                    DataCell(Text('All')),
                    DataCell(Text('3')),
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
