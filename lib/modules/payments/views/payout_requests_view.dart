import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class PayoutRequestsView extends StatelessWidget {
  const PayoutRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final payouts = MockData.withdrawals;
    return AdminLayout(
      title: 'Payout Requests'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payout requests'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Artisan'.tr)),
                DataColumn(label: Text('Amount'.tr)),
                DataColumn(label: Text('IBAN'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: payouts
                  .map(
                    (p) => DataRow(
                      cells: [
                        DataCell(Text(p.artisan)),
                        DataCell(Text('AED ${p.amount.toStringAsFixed(0)}')),
                        DataCell(Text(p.iban)),
                        DataCell(Text(p.status)),
                        DataCell(
                          TextButton(
                            onPressed: () {},
                            child: Text('View details'.tr),
                          ),
                        ),
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
