import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/payments_controller.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/shimmer_widgets.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return AdminLayout(
      title: 'Transactions'.tr,
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
        if (controller.transactions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transactions'.tr,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.md),
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Customer'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Method'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                ],
                rows: controller.transactions
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(Text((p['customerName'] ?? p['customerId'] ?? '').toString())),
                          DataCell(Text(_formatAmount(p))),
                          DataCell(Text((p['method'] ?? p['paymentMethod'] ?? '').toString())),
                          DataCell(Text(_formatDate(p['date'] ?? p['createdAt']))),
                          DataCell(Text((p['status'] ?? '').toString())),
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
        );
      }),
    );
  }

  String _formatAmount(Map<String, dynamic> p) {
    final credit = double.tryParse((p['credit'] ?? p['amount'] ?? 0).toString()) ?? 0;
    final debit = double.tryParse((p['debit'] ?? 0).toString()) ?? 0;
    final value = credit > 0 ? credit : -debit;
    final prefix = credit > 0 ? '+' : '';
    return 'EG $prefix${value.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }
}


