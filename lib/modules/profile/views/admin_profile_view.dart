import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Admin Profile'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: const Icon(Icons.person, color: AppColors.text, size: 32),
              ),
              const SizedBox(width: AppSizes.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Aisha Noor', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('admin@usta.com', style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notification preferences'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSizes.sm),
                Text('Toggle email, SMS, and push notifications (UI only)'.tr, style: const TextStyle(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
