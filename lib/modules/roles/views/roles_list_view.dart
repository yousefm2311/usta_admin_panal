import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/utils/notify.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/roles_controller.dart';

class RolesListView extends StatelessWidget {
  const RolesListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RolesController());
    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading();
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }
        if (controller.roles.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Roles & Permissions'.tr,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openDialog(controller),
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Add'.tr,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                TextButton.icon(
                  onPressed: () => _openAdminDialog(controller),
                  icon: const Icon(Icons.person_add, color: AppColors.primary),
                  label: Text(
                    'Add admin'.tr,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Role'.tr)),
                  DataColumn(label: Text('Modules'.tr)),
                  DataColumn(label: Text('Members'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.roles
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(Text((r['name'] ?? '').toString())),
                          DataCell(
                            Tooltip(
                              message: (r['permissions'] as List)
                                  .map((p) => p['module'])
                                  .join(', '),
                              child: Text(
                                "${(r['permissions'] as List).length} ${'Modules'.tr}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                          DataCell(Text((r['members'] ?? '').toString())),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                    '/roles/permissions',
                                    arguments: r,
                                  ),
                                  child: Text('Edit'.tr),
                                ),
                                TextButton(
                                  onPressed: () => controller.deleteRole(
                                    (r['_id'] ?? r['id'] ?? '').toString(),
                                  ),
                                  child: Text(
                                    'Delete'.tr,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _openDialog(RolesController controller) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Add role'.tr,
          style: const TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Optional: create admin with this role'.tr,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Admin email'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              style: const TextStyle(color: AppColors.text),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }
              controller.create({
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                if (emailCtrl.text.trim().isNotEmpty)
                  'adminEmail': emailCtrl.text.trim(),
                if (passwordCtrl.text.trim().isNotEmpty)
                  'adminPassword': passwordCtrl.text.trim(),
              });
              Get.back();
            },
            child: Text(
              'Save'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _openAdminDialog(RolesController controller) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          'Add admin'.tr,
          style: const TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              style: const TextStyle(color: AppColors.text),
              obscureText: true,
            ),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'Role name'),
              style: const TextStyle(color: AppColors.text),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel'.tr,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  emailCtrl.text.trim().isEmpty ||
                  passwordCtrl.text.trim().isEmpty ||
                  roleCtrl.text.trim().isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }
              await controller.createAdmin(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                password: passwordCtrl.text.trim(),
                role: roleCtrl.text.trim(),
              );
              Get.back();
            },
            child: Text(
              'Save'.tr,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
