import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class RewardsView extends StatelessWidget {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Rewards'.tr,
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
            Text('Rewards levels & points placeholder'.tr, style: const TextStyle(color: AppColors.text)),
            const SizedBox(height: AppSizes.sm),
            Text('Redeem history list'.tr, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
