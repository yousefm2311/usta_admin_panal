import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/artisans_controller.dart';

class ArtisansListView extends StatelessWidget {
  const ArtisansListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ArtisansController());

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
              IconButton(
                onPressed: controller.loadArtisans,
                icon: const Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            if (controller.artisans.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name'.tr)),
                  DataColumn(label: Text('Category'.tr)),
                  DataColumn(label: Text('Rating'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.artisans
                    .map(
                      (artisan) => DataRow(
                        cells: [
                          DataCell(Text(artisan['name']?.toString() ?? '')),
                          DataCell(Text(artisan['category']?.toString() ?? '')),
                          DataCell(Text(artisan['rating']?.toString() ?? '0')),
                          DataCell(_statusChip(artisan['status']?.toString() ?? '')),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Get.toNamed('/artisan/details', arguments: artisan),
                                  child: Text('View details'.tr),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                TextButton(
                                  onPressed: () => controller.approve(artisan['id']?.toString() ?? ''),
                                  child: Text('Approve'.tr, style: const TextStyle(color: AppColors.success)),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                TextButton(
                                  onPressed: () => controller.reject(artisan['id']?.toString() ?? ''),
                                  child: Text('Reject'.tr, style: const TextStyle(color: Colors.redAccent)),
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
                headingRowColor: MaterialStateProperty.all(AppColors.overlay),
                dividerThickness: 0.2,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final isApproved = status.toLowerCase() == 'approved' || status.toLowerCase() == 'active';
    final color = isApproved ? AppColors.success : AppColors.warning;
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
