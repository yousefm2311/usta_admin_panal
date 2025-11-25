import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class SettingsCommissionView extends StatefulWidget {
  const SettingsCommissionView({super.key});

  @override
  State<SettingsCommissionView> createState() => _SettingsCommissionViewState();
}

class _SettingsCommissionViewState extends State<SettingsCommissionView> {
  double commission = 12;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Commission',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission settings'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Commission percentage'.tr, style: const TextStyle(color: AppColors.text)),
                    const Spacer(),
                    Text('${commission.toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.primary)),
                  ],
                ),
                Slider(
                  value: commission,
                  min: 0,
                  max: 30,
                  divisions: 30,
                  label: '${commission.toStringAsFixed(0)}%',
                  activeColor: AppColors.primary,
                  onChanged: (value) => setState(() => commission = value),
                ),
                const SizedBox(height: AppSizes.md),
                Text(
                  'This slider updates the service commission applied to every completed request.'.tr,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
