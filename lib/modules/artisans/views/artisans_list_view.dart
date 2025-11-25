import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';

class ArtisansListView extends StatelessWidget {
  const ArtisansListView({super.key});

  @override
  Widget build(BuildContext context) {
    final artisans = MockData.artisans;

    return AdminLayout(
      title: 'Artisans',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Artisans'.tr,
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, size: 18, color: AppColors.textMuted),
                    const SizedBox(width: AppSizes.xs),
                    Text('Status filter'.tr, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          TableWrapper(
            child: DataTable(
              columns: [
                DataColumn(label: Text('Name'.tr)),
                DataColumn(label: Text('Category'.tr)),
                DataColumn(label: Text('Rating'.tr)),
                DataColumn(label: Text('Status'.tr)),
                DataColumn(label: Text('Actions'.tr)),
              ],
              rows: artisans
                  .map(
                    (artisan) => DataRow(
                      cells: [
                        DataCell(Text(artisan.name)),
                        DataCell(Text(artisan.category)),
                        DataCell(
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(artisan.rating.toStringAsFixed(1)),
                            ],
                          ),
                        ),
                        DataCell(_statusChip(artisan.status)),
                        DataCell(
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Get.toNamed('/artisan/details'),
                                child: Text('View details'.tr),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: artisan.status == 'Approved'
                                        ? Colors.transparent
                                        : AppColors.success,
                                  ),
                                  foregroundColor: AppColors.text,
                                ),
                                onPressed: () {},
                                child: Text('Approve'.tr),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border),
                                  foregroundColor: AppColors.text,
                                ),
                                onPressed: () {},
                                child: Text('Reject'.tr),
                              ),
                            ],
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
    switch (status) {
      case 'Approved':
        color = AppColors.success;
        break;
      case 'Pending':
        color = AppColors.warning;
        break;
      case 'Rejected':
        color = AppColors.danger;
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
