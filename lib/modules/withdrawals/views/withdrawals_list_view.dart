import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class WithdrawalsListView extends StatelessWidget {
  const WithdrawalsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final withdrawals = MockData.withdrawals;

    return AdminLayout(
      title: 'Withdrawals',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Withdrawals'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Artisan'.tr)),
                DataColumn(label: Text('Amount'.tr)),
                DataColumn(label: Text('IBAN'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Action'.tr)),
              ],
              rows: withdrawals
                  .map(
                    (w) => DataRow(
                      cells: [
                        DataCell(Text(w.artisan)),
                        DataCell(Text('EG ${w.amount.toStringAsFixed(0)}')),
                        DataCell(Text(w.iban)),
                        DataCell(_statusChip(w.status)),
                        DataCell(
                          ElevatedButton(
                            onPressed: () {},
                            child: Text('Approve'.tr),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              headingTextStyle: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              dataTextStyle: const TextStyle(color: AppColors.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'Approved' ? AppColors.success : AppColors.warning;
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
