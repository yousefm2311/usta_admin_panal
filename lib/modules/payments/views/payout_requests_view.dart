import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../../withdrawals/controllers/withdrawals_controller.dart';

class PayoutRequestsView extends StatelessWidget {
  const PayoutRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalsController());
    return AdminLayout(
      title: 'Payout Requests'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (controller.withdrawals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payout requests'.tr,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
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
                rows: controller.withdrawals
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(Text((p['artisan'] ?? p['artisanName'] ?? '').toString())),
                          DataCell(Text((p['amount'] ?? '').toString())),
                          DataCell(Text((p['iban'] ?? '').toString())),
                          DataCell(Text((p['status'] ?? '').toString())),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => controller.approve(p['id']?.toString() ?? p['_id']?.toString() ?? ''),
                                  child: Text('Approve'.tr, style: const TextStyle(color: AppColors.success)),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                TextButton(
                                  onPressed: controller.loadWithdrawals,
                                  child: Text('Refresh'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
