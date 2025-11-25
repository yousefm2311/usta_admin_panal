import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';

class SettingsGeneralView extends StatelessWidget {
  const SettingsGeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General settings'.tr,
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
                Text('App logo'.tr, style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      ),
                      child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: AppSizes.md),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.upload),
                      label: Text('Upload logo'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                TextField(
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Support email'.tr),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  style: const TextStyle(color: AppColors.text),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'About info'.tr,
                    hintText: 'Short description about USTA platform'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(
                  expand: true,
                  label: 'Save changes'.tr,
                  icon: Icons.save_outlined,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
