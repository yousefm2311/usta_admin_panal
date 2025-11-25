import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final order = MockData.requests.first;
    return AdminLayout(
      title: 'Order Details'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _card(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.service, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${order.customer} • ${order.artisan}', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                _statusChip(order.status),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat (view only)'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.sm),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.overlay,
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  ),
                    child: const Center(
                    child: Text('Conversation history placeholder', style: TextStyle(color: AppColors.textMuted)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payment info'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.sm),
                _priceRow('Service total'.tr, 'AED ${order.price.toStringAsFixed(0)}'),
                _priceRow('Platform fee'.tr, 'AED ${(order.price * 0.1).toStringAsFixed(2)}'),
                const Divider(color: AppColors.border),
                _priceRow('Total'.tr, 'AED ${(order.price * 1.1).toStringAsFixed(2)}', bold: true),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.cancel_outlined),
                label: Text('Cancel'.tr),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  foregroundColor: AppColors.text,
                ),
                onPressed: () {},
                icon: const Icon(Icons.check_circle_outline),
                label: Text('Close order'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: AppColors.textMuted, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: AppColors.text, fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
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

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
        color = Colors.amber;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(status.tr, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
