import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_config.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/settings_general_controller.dart';
import '../../../widgets/shimmer_widgets.dart';
import 'package:file_picker/file_picker.dart';

class SettingsGeneralView extends StatelessWidget {
  const SettingsGeneralView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsGeneralController());
    final appNameController = TextEditingController();
    final emailController = TextEditingController();
    final aboutController = TextEditingController();

    return AdminLayout(
      title: 'Settings',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 6);
        }
        appNameController.text = controller.form['appName']?.value ?? '';
        emailController.text = controller.form['supportEmail']?.value ?? '';
        aboutController.text = controller.form['about']?.value ?? '';

        return Column(
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
                      Obx(
                        () => Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: AppColors.overlay,
                            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                            image: () {
                              final raw = controller.form['logoUrl']?.value ?? '';
                              if (raw.isEmpty) return null;
                              final url = raw.startsWith('http') ? raw : '${AppConfig.baseUrl}$raw';
                              return DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              );
                            }(),
                          ),
                          child: controller.form['logoUrl']?.value.isNotEmpty == true
                              ? null
                              : const Icon(Icons.image_outlined, color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: controller.uploadingLogo.value
                            ? null
                            : () async {
                                final result =
                                    await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
                                if (result != null && result.files.isNotEmpty) {
                                  final file = result.files.first;
                                  await controller.uploadLogo(
                                    fileName: file.name,
                                    bytes: file.bytes,
                                    path: file.path,
                                  );
                                }
                              },
                        icon: controller.uploadingLogo.value
                            ? const ShimmerBox(height: 16, width: 16, radius: 6)
                            : const Icon(Icons.upload),
                        label: Text('Upload logo'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),
                  TextField(
                    controller: appNameController,
                    onChanged: (v) => controller.form['appName']?.value = v,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'App Name'),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: emailController,
                    onChanged: (v) => controller.form['supportEmail']?.value = v,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'Support email'.tr),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextField(
                    controller: aboutController,
                    onChanged: (v) => controller.form['about']?.value = v,
                    style: const TextStyle(color: AppColors.text),
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'About info'.tr,
                      hintText: 'Short description about USTA platform'.tr,
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Obx(
                    () => PrimaryButton(
                      expand: true,
                      label: controller.saving.value ? 'Loading'.tr : 'Save changes'.tr,
                      icon: Icons.save_outlined,
                      onPressed: controller.saving.value ? null : controller.save,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}


