import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/payments_controller.dart';

class PaymentsListView extends StatelessWidget {
  const PaymentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Payments'.tr,
                style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side:  BorderSide(color: AppColors.border),
                ),
                onPressed: () => _openFilterDialog(context, controller),
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text('Filter'.tr),
              ),
              const SizedBox(width: AppSizes.sm),
              Obx(
                () => OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side:  BorderSide(color: AppColors.border),
                  ),
                  onPressed: controller.filter.isEmpty ? null : controller.clearFilter,
                  icon: const Icon(Icons.clear, size: 18),
                  label: Text('Clear filters'.tr),
                ),
              ),
              IconButton(
                onPressed: controller.loadTransactions,
                icon:  Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 10,);
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
                child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Customer'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Method'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.transactions
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(Text((p['customer']?['name'] ?? '').toString())),
                          DataCell(Text(p['finalAmount']?.toString() ?? '0')),
                          DataCell(Text((p['method'] ?? '').toString())),
                          DataCell(Text(_formatDate(p['date'] ?? p['createdAt']))),
                          DataCell(Text((p['status'] ?? '').toString())),
                          DataCell(
                            TextButton(
                              onPressed: () => Get.toNamed('/payment/details', arguments: p),
                              child: Text('View details'.tr),
                            ),
                          ),
                        ],
                      ),
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

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  void _openFilterDialog(BuildContext context, PaymentsController controller) {
    final statusCtrl = TextEditingController(text: controller.filter['status']?.toString() ?? '');
    final methodCtrl = TextEditingController(text: controller.filter['method']?.toString() ?? '');
    final customerCtrl = TextEditingController(text: controller.filter['customerId']?.toString() ?? '');
    final artisanCtrl = TextEditingController(text: controller.filter['artisanId']?.toString() ?? '');
    final fromCtrl = TextEditingController(text: controller.filter['from']?.toString() ?? '');
    final toCtrl = TextEditingController(text: controller.filter['to']?.toString() ?? '');
    final minCtrl = TextEditingController(text: controller.filter['min']?.toString() ?? '');
    final maxCtrl = TextEditingController(text: controller.filter['max']?.toString() ?? '');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Filters'.tr, style:  TextStyle(color: AppColors.text)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: statusCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'Status'.tr),
              ),
              TextField(
                controller: methodCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'Method'.tr),
              ),
              TextField(
                controller: customerCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'Customer ID'.tr),
              ),
              TextField(
                controller: artisanCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'Artisan ID'.tr),
              ),
              TextField(
                controller: fromCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'From (ISO date)'.tr),
              ),
              TextField(
                controller: toCtrl,
                style:  TextStyle(color: AppColors.text),
                decoration: InputDecoration(labelText: 'To (ISO date)'.tr),
              ),
              TextField(
                controller: minCtrl,
                style:  TextStyle(color: AppColors.text),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Min amount'.tr),
              ),
              TextField(
                controller: maxCtrl,
                style:  TextStyle(color: AppColors.text),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Max amount'.tr),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr, style:  TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final params = <String, dynamic>{};
              if (statusCtrl.text.trim().isNotEmpty) params['status'] = statusCtrl.text.trim();
              if (methodCtrl.text.trim().isNotEmpty) params['method'] = methodCtrl.text.trim();
              if (customerCtrl.text.trim().isNotEmpty) params['customerId'] = customerCtrl.text.trim();
              if (artisanCtrl.text.trim().isNotEmpty) params['artisanId'] = artisanCtrl.text.trim();
              if (fromCtrl.text.trim().isNotEmpty) params['from'] = fromCtrl.text.trim();
              if (toCtrl.text.trim().isNotEmpty) params['to'] = toCtrl.text.trim();
              final minVal = double.tryParse(minCtrl.text.trim());
              if (minVal != null) params['min'] = minVal;
              final maxVal = double.tryParse(maxCtrl.text.trim());
              if (maxVal != null) params['max'] = maxVal;
              controller.applyFilter(params);
            },
            child: Text('Apply filters'.tr, style:  TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}


