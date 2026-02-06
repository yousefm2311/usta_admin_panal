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
    if (id.isNotEmpty &&
        controller.payout.value == null &&
        !controller.loading.value) {
      controller.loadPayout(id);
    }

    return AdminLayout(
      title: 'Payout Details'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 200, lines: 4);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        final payout = controller.payout.value;
        if (payout == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        final artisanName = controller.artisanNameFor(payout);
        final iban = controller.ibanFor(payout);
        final amount = controller.amountFor(payout);
        final method = controller.methodFor(payout);
        final status = (payout['status'] ?? '').toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artisanName.isEmpty ? 'Unknown artisan'.tr : artisanName,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'IBAN: ${iban.isEmpty ? '—' : iban}',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Amount: ${_amountText(amount)}',
                    style: TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Method: ${method.isEmpty ? '—' : method}',
                    style: TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Status: ${status.isEmpty ? '—' : status}',
                    style: TextStyle(color: AppColors.text),
                  ),
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
                    side: BorderSide(color: AppColors.border),
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
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  String _amountText(dynamic value) {
    final n = double.tryParse(value.toString()) ?? 0;
    final abs = n.abs();

    if (abs >= 1000000) {
      return 'EGP ${(n / 1000000).toStringAsFixed(1)}M';
    }
    if (abs >= 1000) {
      return 'EGP ${(n / 1000).toStringAsFixed(1)}K';
    }
    if (n % 1 == 0) {
      return 'EGP ${n.toInt()}';
    }
    return 'EGP ${n.toStringAsFixed(2)}';
  }
}
