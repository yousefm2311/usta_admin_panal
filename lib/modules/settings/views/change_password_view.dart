import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change password'.tr,
            style:  TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _currentController,
                    obscureText: true,
                    style:  TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'Current password'.tr),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Current password'.tr;
                      }
                      if (value.trim().length < 6) {
                        return 'Password too short'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _newController,
                    obscureText: true,
                    style:  TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'New password'.tr),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'New password'.tr;
                      }
                      if (value.trim().length < 6) {
                        return 'Password too short'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    style:  TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'Confirm password'.tr),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Confirm password'.tr;
                      }
                      if (value.trim() != _newController.text.trim()) {
                        return 'Passwords do not match'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Obx(
                    () => PrimaryButton(
                      expand: true,
                      label: controller.saving.value ? 'Loading'.tr : 'Save changes'.tr,
                      icon: Icons.lock_reset,
                      onPressed: controller.saving.value
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              final ok = await controller.changePassword(
                                currentPassword: _currentController.text.trim(),
                                newPassword: _newController.text.trim(),
                              );
                              if (ok) {
                                _currentController.clear();
                                _newController.clear();
                                _confirmController.clear();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
