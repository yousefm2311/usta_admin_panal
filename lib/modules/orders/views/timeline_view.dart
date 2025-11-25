import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class OrderTimelineView extends StatelessWidget {
  const OrderTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Created'.tr, Icons.play_arrow),
      ('Assigned Artisan'.tr, Icons.person_add_alt_1),
      ('On the way'.tr, Icons.directions_walk),
      ('Working'.tr, Icons.handyman),
      ('Completed'.tr, Icons.check_circle),
    ];

    return AdminLayout(
      title: 'Timeline'.tr,
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
            Text('Timeline'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.md),
            ...steps.asMap().entries.map(
              (e) => Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        child: Icon(e.value.$2, color: AppColors.primary),
                      ),
                      if (e.key != steps.length - 1)
                        Container(
                          width: 2,
                          height: 40,
                          color: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: AppSizes.md),
                  Text(e.value.$1.tr, style: const TextStyle(color: AppColors.text)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
