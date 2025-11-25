import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class WalletSummaryView extends StatelessWidget {
  const WalletSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Wallet Summary'.tr,
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
            Text('Wallet balances placeholder'.tr, style: const TextStyle(color: AppColors.text)),
            const SizedBox(height: AppSizes.sm),
            Text('Per customer / artisan balance list'.tr, style: const TextStyle(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
