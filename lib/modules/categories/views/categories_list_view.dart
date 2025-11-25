import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class CategoriesListView extends StatelessWidget {
  const CategoriesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final categories = MockData.categories;

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
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            children: categories
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
                          backgroundColor: category.color.withOpacity(0.16),
                          child: Icon(category.icon, color: category.color),
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          category.name,
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
                          onPressed: () {},
                          child: Text('Delete'.tr),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
