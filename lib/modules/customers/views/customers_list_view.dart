import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final customers = MockData.customers;

    return AdminLayout(
      title: 'Customers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Customers list'.tr,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                    hintText: 'Search by name or phone'.tr,
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name'.tr)),
                DataColumn(label: Text('Phone'.tr)),
                DataColumn(label: Text('Requests count'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: [
                for (final customer in customers)
                  DataRow(
                    cells: [
                      DataCell(Text(customer.name)),
                      DataCell(Text(customer.phone)),
                      DataCell(Text(customer.requests.toString())),
                      DataCell(_statusChip(customer.status)),
                      DataCell(
                        TextButton(
                          onPressed: () => Get.toNamed('/customer/details'),
                          child: Text('View details'.tr),
                        ),
                      ),
                    ],
                  ),
              ],
              headingTextStyle: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              dataTextStyle: const TextStyle(color: AppColors.text),
              headingRowColor: MaterialStateProperty.all(AppColors.overlay),
              dividerThickness: 0.2,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () {},
                  child: Text('Prev'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: () {},
                  child: Text('Next'.tr),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status == 'Active' ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
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
