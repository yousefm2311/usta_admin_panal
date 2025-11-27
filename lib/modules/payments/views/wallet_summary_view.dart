import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/payouts_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class WalletSummaryView extends StatelessWidget {
  const WalletSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PayoutsController());
    controller.loadWallets();
    return AdminLayout(
      title: 'Wallet Summary'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 200, lines: 4);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (controller.wallets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Wallet balances'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              ...controller.wallets.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          (w['owner'] ?? w['name'] ?? w['user'] ?? '').toString(),
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                      Text(
                        (w['balance'] ?? w['amount'] ?? '').toString(),
                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}


