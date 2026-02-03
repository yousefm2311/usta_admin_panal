import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/withdrawals_controller.dart';

class WithdrawalsListView extends StatelessWidget {
  const WithdrawalsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalsController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Withdrawals'.tr,
                style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadWithdrawals,
                icon:  Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
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
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Artisan'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('IBAN'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Action'.tr)),
                ],
                rows: controller.withdrawals
                    .map(
                      (w) {
                        final status = (w['status'] ?? '').toString();
                        final canApprove = _isPendingStatus(status);
                        return DataRow(
                          cells: [
                            DataCell(Text((w['artisan'] ?? w['artisanName'] ?? '').toString())),
                            DataCell(Text(w['amount']?.toString() ?? '0')),
                            DataCell(Text((w['iban'] ?? '').toString())),
                            DataCell(_statusChip(status)),
                            DataCell(
                              Row(
                                children: [
                                  if (canApprove)
                                    ElevatedButton(
                                      onPressed: () => controller.approve(w['id']?.toString() ?? ''),
                                      child: Text('Approve'.tr),
                                    ),
                                  if (canApprove) const SizedBox(width: AppSizes.xs),
                                  if (canApprove)
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side:  BorderSide(color: AppColors.border),
                                        foregroundColor: AppColors.text,
                                      ),
                                      onPressed: () => controller.reject(w['id']?.toString() ?? ''),
                                      child: Text('Reject'.tr),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )
                    .toList(),
                headingTextStyle:  TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle:  TextStyle(color: AppColors.text),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status.toLowerCase() == 'approved' ? AppColors.success : AppColors.warning;
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


