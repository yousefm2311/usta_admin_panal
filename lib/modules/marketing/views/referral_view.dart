import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/referral_controller.dart';

class ReferralView extends StatelessWidget {
  const ReferralView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReferralController());
    return AdminLayout(
      title: 'Referral'.tr,
      child: Obx(() {
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
        final data = controller.data.value;
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
              Text('Referral'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSizes.sm),
              if (data != null)
                ...[
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.sm,
                    children: [
                      _pill('Total referrals'.tr, (data['total'] ?? data['count'] ?? data['totalReferrals'] ?? '0').toString()),
                      _pill('Active'.tr, (data['active'] ?? data['activeReferrals'] ?? data['activeCount'] ?? '0').toString()),
                      _pill('Rewards'.tr, (data['rewards'] ?? data['points'] ?? '0').toString()),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Top referrers'.tr, style: const TextStyle(color: AppColors.text)),
                  const SizedBox(height: AppSizes.xs),
                  ...(data['top'] ?? data['topReferrers'] ?? <dynamic>[])
                      .map<Widget>(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.xs),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (item['name'] ?? item['user'] ?? '').toString(),
                                  style: const TextStyle(color: AppColors.text),
                                ),
                              ),
                              Text((item['count'] ?? item['referrals'] ?? '').toString(),
                                  style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ]
              else
                Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        );
      }),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
