import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class RolePermissionsView extends StatelessWidget {
  const RolePermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      'Dashboard',
      'Customers',
      'Artisans',
      'Orders',
      'Payments',
      'Complaints',
      'Notifications',
      'Marketing',
      'Settings',
    ];

    return AdminLayout(
      title: 'Role Permissions'.tr,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign permissions'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.md),
            ...modules.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    Expanded(child: Text(m.tr, style: const TextStyle(color: AppColors.text))),
                    _permChip('Read'),
                    const SizedBox(width: AppSizes.sm),
                    _permChip('Create'),
                    const SizedBox(width: AppSizes.sm),
                    _permChip('Update'),
                    const SizedBox(width: AppSizes.sm),
                    _permChip('Delete'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permChip(String label) {
    return FilterChip(
      label: Text(label.tr),
      selected: true,
      onSelected: (_) {},
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
