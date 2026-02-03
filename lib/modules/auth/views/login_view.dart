import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/auth_controller.dart';
import '../../../core/utils/notify.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final AuthController auth;
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    auth = Get.put(AuthController());
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              border: Border.fromBorderSide(
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
                      child: Icon(
                        Icons.shield_moon,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'USTA Platform'.tr,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Admin Panel'.tr,
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Sign in to continue'.tr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: emailCtrl,
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Email address'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Password'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.offAllNamed('/reset');
                      },
                      child: Text(
                        'Forgot password?'.tr,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Obx(
                  () => PrimaryButton(
                    expand: true,
                    label: 'Sign in'.tr,
                    loadingLabel: 'Loading'.tr,
                    isLoading: auth.loading.value,
                    icon: Icons.lock_open,
                    onPressed: () async {
                      final ok = await auth.login(
                        emailCtrl.text.trim(),
                        passCtrl.text.trim(),
                      );
                      if (ok) {
                        Get.offAllNamed('/dashboard');
                      } else if (auth.error.value != null) {
                        showError(auth.error.value!);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
