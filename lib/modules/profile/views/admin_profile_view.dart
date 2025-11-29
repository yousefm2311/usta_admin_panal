import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/profile_controller.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 220, lines: 5);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final data = controller.profile.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        final name = (data['name'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        final role = (data['role'] ?? data['kind'] ?? '').toString();
        final language = (data['settings']?['language'] ?? '').toString();
        final theme = (data['settings']?['theme'] ?? '').toString();
        final createdAt = (data['createdAt'] ?? '').toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withOpacity(0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.text, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(email, style: const TextStyle(color: AppColors.textMuted)),
                    if (role.isNotEmpty)
                      Text(role.tr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
                  Text('Account info'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  _infoRow('Email'.tr, email),
                  _infoRow('Role'.tr, role),
                  _infoRow('Language'.tr, language),
                  _infoRow('Theme'.tr, theme),
                  if (createdAt.isNotEmpty) _infoRow('Created at'.tr, createdAt),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}


