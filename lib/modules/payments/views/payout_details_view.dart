import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/payouts_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class PayoutDetailsView extends StatelessWidget {
  const PayoutDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(PayoutsController());
    if (id.isNotEmpty) controller.loadPayout(id);

    return AdminLayout(
      title: 'Payout Details'.tr,
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
        final payout = controller.payout.value;
        if (payout == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((payout['artisan'] ?? payout['name'] ?? '').toString(),
                      style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('IBAN: ${(payout['iban'] ?? '').toString()}',
                      style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 6),
                  Text('Amount: ${(payout['amount'] ?? '').toString()}', style: const TextStyle(color: AppColors.text)),
                  const SizedBox(height: 6),
                  Text('Status: ${(payout['status'] ?? '').toString()}',
                      style: const TextStyle(color: AppColors.text)),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.updateStatus(id, 'approved'),
                  icon: const Icon(Icons.check),
                  label: Text('Approve'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                  ),
                  onPressed: () => controller.updateStatus(id, 'rejected'),
                  child: Text('Reject'.tr),
                ),
              ],
            ),
          ],
        );
      }),
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


