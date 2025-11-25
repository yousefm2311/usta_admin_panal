import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class ComplaintDetailsView extends StatelessWidget {
  const ComplaintDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Complaint Details'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Issue: Payment delay'.tr,
                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Customer: Layla Ibrahim • Artisan: Hassan Mahmoud'.tr,
                    style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thread'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.sm),
                ...List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      ),
                      child: Text('Conversation history placeholder'.tr, style: const TextStyle(color: AppColors.text)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              ElevatedButton(onPressed: () {}, child: Text('Assign to support'.tr)),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.text,
                ),
                onPressed: () {},
                child: Text('Close'.tr),
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
