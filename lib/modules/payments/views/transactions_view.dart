import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final payments = MockData.payments;
    return AdminLayout(
      title: 'Transactions'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Customer'.tr)),
                DataColumn(label: Text('Amount'.tr)),
                DataColumn(label: Text('Method'.tr)),
                DataColumn(label: Text('Date'.tr)),
              ],
              rows: payments
                  .map(
                    (p) => DataRow(
                      cells: [
                        DataCell(Text(p.customer)),
                        DataCell(Text('AED ${p.amount.toStringAsFixed(0)}')),
                        DataCell(Text(p.method)),
                        DataCell(Text('${p.date.day}/${p.date.month}/${p.date.year}')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
