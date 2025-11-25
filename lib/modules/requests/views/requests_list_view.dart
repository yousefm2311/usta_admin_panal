import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final requests = filter == 'All'
        ? MockData.requests
        : MockData.requests.where((r) => r.status.toLowerCase() == filter.toLowerCase()).toList();

    return AdminLayout(
      title: 'Requests',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Requests'.tr,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSizes.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: AppSizes.sm,
                  children: ['All', 'Pending', 'Accepted', 'In progress', 'Completed']
                      .map(
                        (status) => ChoiceChip(
                          label: Text(status.tr),
                          selected: filter == status,
                          onSelected: (_) => setState(() => filter = status),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.card,
                          labelStyle: TextStyle(
                            color: filter == status ? Colors.white : AppColors.textMuted,
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
                DataColumn(label: Text('Date'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: requests
                  .map(
                    (r) => DataRow(
                      cells: [
                        DataCell(Text(r.service)),
                        DataCell(Text(r.customer)),
                        DataCell(Text(r.artisan)),
                        DataCell(_statusChip(r.status)),
                        DataCell(Text('${r.date.day}/${r.date.month}/${r.date.year}')),
                        DataCell(
                          TextButton(
                            onPressed: () => Get.toNamed('/request/details'),
                            child: Text('View details'.tr),
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
