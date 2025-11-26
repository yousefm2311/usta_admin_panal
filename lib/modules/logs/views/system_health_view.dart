import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class SystemHealthView extends StatelessWidget {
  const SystemHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('API status', 'Operational', AppColors.success),
      ('Storage', '78% used', Colors.amber),
      ('Performance', 'Stable', AppColors.success),
    ];

    return AdminLayout(
      title: 'System Health'.tr,
      child: Wrap(
        spacing: AppSizes.md,
        runSpacing: AppSizes.md,
        children: items
            .map(
              (item) => Container(
                width: 220,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(item.$2, style: TextStyle(color: item.$3, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
