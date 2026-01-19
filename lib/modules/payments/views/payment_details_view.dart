import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/payment_details_controller.dart';

class PaymentDetailsView extends StatelessWidget {
  const PaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(PaymentDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 200, lines: 6);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final payment = controller.payment.value;
        if (payment == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment details'.tr,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Status'.tr, (payment['status'] ?? '').toString()),
                  _row('Method'.tr, (payment['method'] ?? payment['paymentMethod'] ?? '').toString()),
                  _row('Amount'.tr, _formatAmount(payment)),
                  _row('Customer'.tr, _resolveName(payment['customer'] ?? payment['customerId'])),
                  _row('Artisan'.tr, _resolveName(payment['artisan'] ?? payment['artisanId'])),
                  _row('Date'.tr, (payment['createdAt'] ?? payment['date'] ?? '').toString()),
                  _row('Reference'.tr, (payment['reference'] ?? payment['ref'] ?? '').toString()),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Raw payload'.tr,
                    style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  SelectableText(
                    payment.toString(),
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value, style: const TextStyle(color: AppColors.text)),
          ),
        ],
      ),
    );
  }

  String _resolveName(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['name'] ?? value['fullName'] ?? value['email'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  String _formatAmount(Map<String, dynamic> payment) {
    final amount = payment['amount'] ?? payment['finalAmount'] ?? payment['total'] ?? payment['value'] ?? 0;
    final parsed = double.tryParse(amount.toString()) ?? 0;
    return 'EG ${parsed.toStringAsFixed(2)}';
  }
}
