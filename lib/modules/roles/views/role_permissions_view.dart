import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/role_permissions_controller.dart';

class RolePermissionsView extends StatelessWidget {
  const RolePermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(RolePermissionsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: 'Role Permissions'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final permissions = controller.permissions;
        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assign permissions'.tr,
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSizes.md),
              ...permissions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Row(
                    children: [
                      Expanded(
                          child:
                              Text((entry.value['module'] ?? '').toString().tr, style: const TextStyle(color: AppColors.text))),
                      _permChip('Read', entry.value['read'] == true, () => controller.toggle(entry.key, 'read')),
                      const SizedBox(width: AppSizes.sm),
                      _permChip('Create', entry.value['create'] == true, () => controller.toggle(entry.key, 'create')),
                      const SizedBox(width: AppSizes.sm),
                      _permChip('Update', entry.value['update'] == true, () => controller.toggle(entry.key, 'update')),
                      const SizedBox(width: AppSizes.sm),
                      _permChip('Delete', entry.value['delete'] == true, () => controller.toggle(entry.key, 'delete')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: controller.save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text('Save'.tr),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _permChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label.tr),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.card,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textMuted),
    );
  }
}
