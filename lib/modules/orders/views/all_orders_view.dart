import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class AllOrdersView extends StatefulWidget {
  const AllOrdersView({super.key});

  @override
  State<AllOrdersView> createState() => _AllOrdersViewState();
}

class _AllOrdersViewState extends State<AllOrdersView> {
  String statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final orders = statusFilter == 'All'
        ? MockData.requests
        : MockData.requests.where((r) => r.status.toLowerCase() == statusFilter.toLowerCase()).toList();

    return AdminLayout(
      title: 'Orders'.tr,
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
                child: Wrap(
                  spacing: AppSizes.sm,
                  children: ['All', 'Active', 'Completed', 'Canceled']
                      .map(
                        (s) => ChoiceChip(
                          label: Text(s.tr),
                          selected: statusFilter == s,
                          onSelected: (_) => setState(() => statusFilter = s),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.card,
                          labelStyle: TextStyle(
                            color: statusFilter == s ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Service'.tr)),
                DataColumn(label: Text('Customer'.tr)),
                DataColumn(label: Text('Artisan'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Price'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: orders
                  .map(
                    (o) => DataRow(
                      cells: [
                        DataCell(Text(o.service)),
                        DataCell(Text(o.customer)),
                        DataCell(Text(o.artisan)),
                        DataCell(_statusChip(o.status)),
                        DataCell(Text('AED ${o.price.toStringAsFixed(0)}')),
                        DataCell(
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Get.toNamed('/order/details'),
                                child: Text('Details'.tr),
                              ),
                              TextButton(
                                onPressed: () => Get.toNamed('/order/timeline'),
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
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
        color = Colors.amber;
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
