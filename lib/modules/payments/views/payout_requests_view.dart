import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../../withdrawals/controllers/withdrawals_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class PayoutRequestsView extends StatelessWidget {
  const PayoutRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalsController());
    return AdminLayout(
      title: 'Payout Requests'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading();
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
            child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payout requests'.tr,
                style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
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
                      (p) {
                        final status = (p['status'] ?? '').toString();
                        final canTakeAction = _isPendingStatus(status);
                        return DataRow(
                          cells: [
                            DataCell(Text((p['artisan'] ?? p['artisanName'] ?? '').toString())),
                            DataCell(Text((p['amount'] ?? '').toString())),
                            DataCell(Text((p['iban'] ?? '').toString())),
                            DataCell(_statusChip(status)),
                            DataCell(
                              Row(
                                children: [
                                  if (canTakeAction)
                                    TextButton(
                                      onPressed: () =>
                                          controller.approve(p['id']?.toString() ?? p['_id']?.toString() ?? ''),
                                      child: Text('Approve'.tr, style:  TextStyle(color: AppColors.success)),
                                    ),
                                  if (canTakeAction) const SizedBox(width: AppSizes.xs),
                                  if (canTakeAction)
                                    TextButton(
                                      onPressed: () =>
                                          controller.reject(p['id']?.toString() ?? p['_id']?.toString() ?? ''),
                                      child: Text('Reject'.tr, style: const TextStyle(color: Colors.redAccent)),
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
                        );
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _statusChip(String status) {
    final isApproved = status.toLowerCase() == 'approved';
    final isRejected = status.toLowerCase() == 'rejected';
    final color = isApproved
        ? AppColors.success
        : isRejected
        ? Colors.redAccent
        : AppColors.warning;
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

  bool _isPendingStatus(String status) {
    final value = status.trim().toLowerCase();
    return value.isEmpty ||
        value == 'pending' ||
        value == 'review' ||
        value == 'in review' ||
        value == 'new';
  }
}


