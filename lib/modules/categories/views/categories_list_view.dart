import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/categories_controller.dart';

class CategoriesListView extends StatelessWidget {
  const CategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final controller = Get.put(CategoriesController());

    return AdminLayout(
      title: 'Categories',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.toNamed('/category/add'),
          icon: const Icon(Icons.add),
          label: Text('New category'.tr),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Service categories'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
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
            if (controller.categories.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: controller.categories
                  .map(
                    (category) => Container(
                      width: isMobile ? double.infinity : 220,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text(
                              (category['icon'] ?? '•').toString().substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          Text(
                            (category['name'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            'Icon preview'.tr,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.text,
                              side: const BorderSide(color: AppColors.border),
                            ),
                            onPressed: () => controller.removeCategory((category['id'] ?? '').toString()),
                            child: Text('Delete'.tr),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}
