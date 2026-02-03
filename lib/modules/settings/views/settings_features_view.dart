import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/settings_features_controller.dart';

class SettingsFeaturesView extends StatefulWidget {
  const SettingsFeaturesView({super.key});

  @override
  State<SettingsFeaturesView> createState() => _SettingsFeaturesViewState();
}

class _SettingsFeaturesViewState extends State<SettingsFeaturesView> {
  final _formKey = GlobalKey<FormState>();
  final _jsonController = TextEditingController(
    text: '{\n  "featureExample": true\n}',
  );

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsFeaturesController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature flags'.tr,
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
                  Text(
                    'Paste features JSON object'.tr,
                    style:  TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  TextFormField(
                    controller: _jsonController,
                    style:  TextStyle(color: AppColors.text),
                    maxLines: 10,
                    decoration: InputDecoration(
                      hintText: '{ "enableFeature": true }',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a JSON payload'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),
                  Obx(() {
                    final error = controller.error.value;
                    if (error == null || error.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Text(error.tr, style: const TextStyle(color: Colors.redAccent)),
                    );
                  }),
                  Obx(
                    () => PrimaryButton(
                      expand: true,
                      label: controller.saving.value ? 'Loading'.tr : 'Save changes'.tr,
                      icon: Icons.save_outlined,
                      onPressed: controller.saving.value
                          ? null
                          : () {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              controller.save(_jsonController.text);
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
    _jsonController.dispose();
    super.dispose();
  }
}
