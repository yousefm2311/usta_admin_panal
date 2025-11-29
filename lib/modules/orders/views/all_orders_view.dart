import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/orders_controller.dart';

class AllOrdersView extends StatelessWidget {
  const AllOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final statuses = ['All', 'New', 'assigned', 'in_progress', 'completed', 'cancelled', 'closed'];

    return AdminLayout(
      title: ''.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Orders'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSizes.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => Wrap(
                    spacing: AppSizes.sm,
                    children: statuses
                        .map(
                          (s) => ChoiceChip(
                            label: Text(s.tr),
                            selected: controller.status.value == s,
                            onSelected: (_) => controller.setStatus(s),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.card,
                            labelStyle: TextStyle(
                              color: controller.status.value == s ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 8);
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            if (controller.orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Service'.tr)),
                  DataColumn(label: Text('Customers'.tr)),
                  DataColumn(label: Text('Artisan'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.orders
                    .map(
                      (o) => DataRow(
                        cells: [
                          DataCell(Text((o['serviceType'] ?? o['service'] ?? '').toString())),
                          DataCell(Text(_resolveName(o['customer']))),
                          DataCell(Text(_resolveName(o['artisan']))),
                          DataCell(_statusChip((o['status'] ?? '').toString())),
                          DataCell(Text(_formatDate(o['createdAt']))),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Get.toNamed('/order/details', arguments: o),
                                  child: Text('Details'.tr),
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed('/order/timeline', arguments: o),
                                  child: Text('Timeline'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
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

  String _resolveName(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['name'] ?? value['customerName'] ?? value['artisanName'] ?? '').toString();
    }
    return (value ?? '').toString();
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
      case 'new':
        color = AppColors.warning;
        break;
      case 'assigned':
        color = Colors.lightBlueAccent;
        break;
      case 'accepted':
      case 'active':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
      case 'in_progress':
        color = Colors.amber;
        break;
      case 'canceled':
      case 'cancelled':
        color = AppColors.danger;
        break;
      case 'closed':
        color = AppColors.textMuted;
        break;
      default:
        color = AppColors.primary;
    }
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


