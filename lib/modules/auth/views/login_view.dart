import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/primary_button.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(
                BorderSide(color: AppColors.border),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                  height: 46,
                  width: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.shield_moon, color: AppColors.primary),
                ),
                const SizedBox(width: AppSizes.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USTA Platform'.tr,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Admin Panel'.tr,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            Text(
              'Sign in to continue'.tr,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Email address'.tr,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              controller: passCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Password'.tr,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Validation only - no backend'.tr, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                Text('Forgot password?'.tr, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            PrimaryButton(
              expand: true,
              label: 'Sign in'.tr,
              icon: Icons.lock_open,
              onPressed: () => Get.offAllNamed('/dashboard'),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}
