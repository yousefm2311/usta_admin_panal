import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();

    return AdminLayout(
      title: 'Reset Password'.tr,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Reset Password'.tr,
                  style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: emailCtrl,
                  style:  TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Email address'.tr),
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(
                  expand: true,
                  label: 'Send reset link'.tr,
                  icon: Icons.send,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
