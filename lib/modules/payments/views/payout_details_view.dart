import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class PayoutDetailsView extends StatelessWidget {
  const PayoutDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final payout = MockData.withdrawals.first;
    return AdminLayout(
      title: 'Payout Details'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payout.artisan, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('IBAN: ${payout.iban}', style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Text('Amount: AED ${payout.amount.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.text)),
                const SizedBox(height: 6),
                Text('Status: ${payout.status}', style: const TextStyle(color: AppColors.text)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: Text('Approve'.tr),
              ),
              const SizedBox(width: AppSizes.sm),
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
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}
