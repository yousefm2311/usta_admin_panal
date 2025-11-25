import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class RequestDetailsView extends StatelessWidget {
  const RequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final request = MockData.requests.first;

    return AdminLayout(
      title: 'Request details',
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
                      _sectionTitle('Service'.tr),
                      const SizedBox(height: 4),
                      Text(request.service, style: const TextStyle(color: AppColors.text, fontSize: 16)),
                      const SizedBox(height: AppSizes.sm),
                      Text('Customer: ${request.customer}', style: const TextStyle(color: AppColors.textMuted)),
                      Text('Artisan: ${request.artisan}', style: const TextStyle(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                _statusChip(request.status),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Status timeline'.tr),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.sm,
                  children: [
                    _timelineStep('Pending', true),
                    _timelineStep('Accepted', true),
                    _timelineStep('In progress', true),
                    _timelineStep('Completed', false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.md),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Images'.tr),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 140,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                        child: Center(
                          child: Text('Image placeholder'.tr, style: const TextStyle(color: AppColors.textMuted)),
                      ),
                    ),
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
                _sectionTitle('Pricing'.tr),
                const SizedBox(height: AppSizes.sm),
                _priceRow('Base price'.tr, 'EG ${request.price.toStringAsFixed(0)}'),
                _priceRow('VAT 5%'.tr, 'EG ${(request.price * 0.05).toStringAsFixed(2)}'),
                const Divider(color: AppColors.border),
                _priceRow(
                  'Total'.tr,
                  'EG ${(request.price * 1.05).toStringAsFixed(2)}',
                  bold: true,
                ),
              ],
            ),
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
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineStep(String label, bool done) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: done ? AppColors.primary : AppColors.border,
          child: Icon(done ? Icons.check : Icons.radio_button_unchecked, size: 14, color: Colors.white),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(label, style: TextStyle(color: done ? AppColors.text : AppColors.textMuted)),
      ],
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

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

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
      child: Text(
        status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
