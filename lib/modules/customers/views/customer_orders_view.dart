import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/customer_orders_controller.dart';

class CustomerOrdersView extends StatelessWidget {
  const CustomerOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final id = (args['_id'] ?? args['id'] ?? '').toString();
    final name = (args['name'] ?? '').toString();
    final controller = Get.put(CustomerOrdersController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(lines: 8);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (controller.orders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name.isEmpty ? 'Orders list'.tr : '${'Orders list'.tr}: $name',
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Service'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.orders
                    .map(
                      (raw) {
                        final r = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                        return DataRow(
                          cells: [
                            DataCell(Text((r['serviceType'] ?? r['service'] ?? '').toString())),
                            DataCell(_statusChip((r['status'] ?? '').toString())),
                            DataCell(Text(_formatMoney(_extractAmount(r)))),
                            DataCell(Text(_formatDate(r['createdAt']))),
                            DataCell(
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => Get.toNamed('/order/details', arguments: r),
                                    child: Text('Details'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.toNamed('/order/timeline', arguments: r),
                                    child: Text('Timeline'.tr),
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

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  dynamic _extractAmount(Map<String, dynamic> r) {
    return r['agreedPrice'] ??
        r['price'] ??
        r['amount'] ??
        r['total'] ??
        r['pricing']?['proposedPrice'] ??
        '';
  }

  String _formatMoney(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toStringAsFixed(2);
  }

  Widget _statusChip(String status) {
    final key = _normalizeStatusKey(status);
    final color = _statusColor(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        key.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  String _normalizeStatusKey(String status) {
    final normalized = status.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'inprogress':
      case 'in_progress':
        return 'in_progress';
      case 'on_the_way':
        return 'on_the_way';
      case 'cancelled':
      case 'canceled':
        return 'cancelled';
      default:
        return normalized;
    }
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'new':
        return AppColors.warning;
      case 'assigned':
      case 'accepted':
      case 'active':
      case 'on_the_way':
        return Colors.lightBlueAccent;
      case 'in_progress':
      case 'working':
        return Colors.amber;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return AppColors.danger;
      case 'closed':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }
}
