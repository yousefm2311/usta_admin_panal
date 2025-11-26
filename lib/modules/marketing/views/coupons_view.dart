import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Coupons'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coupons manager'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Code'.tr)),
                DataColumn(label: Text('Discount'.tr)),
                DataColumn(label: Text('Usage'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: List.generate(
                4,
                (i) => DataRow(
                  cells: const [
                    DataCell(Text('WELCOME')),
                    DataCell(Text('10%')),
                    DataCell(Text('34/100')),
                    DataCell(Text('Active')),
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
