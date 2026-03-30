import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/utils/notify.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
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
              style: TextStyle(color: AppColors.textMuted),
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
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                _primaryButton(
                  icon: Icons.add,
                  label: 'Add'.tr,
                  onTap: () => _openRoleDialog(controller),
                ),
                const SizedBox(width: AppSizes.sm),
                _primaryButton(
                  icon: Icons.person_add,
                  label: 'Add admin'.tr,
                  onTap: () => _openAdminDialog(controller),
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
                rows: controller.roles.map((r) {
                  final roleId = (r['_id'] ?? r['id'] ?? '').toString();
                  final roleName = (r['name'] ?? '').toString();
                  final permissions = (r['permissions'] is List)
                      ? (r['permissions'] as List)
                      : <dynamic>[];
                  final members = (r['members'] ?? '').toString();

                  final modules = permissions
                      .map((p) {
                        if (p is Map) return (p['module'] ?? '').toString();
                        return '';
                      })
                      .where((m) => m.trim().isNotEmpty)
                      .toList();

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          roleName.isEmpty ? '-' : roleName,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      DataCell(_modulesCell(modules)),
                      DataCell(
                        Text(
                          members.isEmpty ? '-' : members,
                          style: TextStyle(color: AppColors.text),
                        ),
                      ),
                      DataCell(
                        _actionsMenu(
                          onEdit: () =>
                              Get.toNamed('/roles/permissions', arguments: r),
                          onDelete: () => _confirmDelete(
                            context,
                            controller,
                            roleId,
                            roleName,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                headingTextStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
                dataTextStyle: TextStyle(color: AppColors.text),
                headingRowColor: MaterialStateProperty.all(AppColors.overlay),
                dividerThickness: 0.2,
              ),
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // UI helpers
  // =========================

  Widget _primaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.primary),
      label: Text(
        label,
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: AppColors.primary.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
        ),
      ),
    );
  }

  Widget _modulesCell(List<String> modules) {
    if (modules.isEmpty) {
      return Text('-', style: TextStyle(color: AppColors.textMuted));
    }

    // Chips preview (first 2) + tooltip full list
    final preview = modules.take(2).toList();
    final rest = modules.length - preview.length;

    return Tooltip(
      message: modules.join(', '),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final m in preview) _chip(m),
          if (rest > 0) _chip('+$rest'),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _actionsMenu({
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return PopupMenuButton<_RoleAction>(
      tooltip: 'Actions'.tr,
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (v) {
        if (v == _RoleAction.edit) onEdit();
        if (v == _RoleAction.delete) onDelete();
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _RoleAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Text('Edit'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: _RoleAction.delete,
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.8)),
        ),
        child: Icon(Icons.more_horiz, color: AppColors.textMuted),
      ),
    );
  }

  // =========================
  // Dialogs
  // =========================

  void _openRoleDialog(RolesController controller) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add role'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(
                  controller: nameCtrl,
                  label: 'Name'.tr,
                  hint: 'Role name'.tr,
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 10),
                _field(
                  controller: descCtrl,
                  label: 'Description'.tr,
                  hint: 'Optional description'.tr,
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.overlay,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Optional: create admin with this role'.tr,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _field(
                  controller: emailCtrl,
                  label: 'Admin email'.tr,
                  hint: 'example@mail.com'.tr,
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 10),
                _field(
                  controller: passwordCtrl,
                  label: 'Password'.tr,
                  hint: '••••••••'.tr,
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }

              final email = emailCtrl.text.trim();
              final pass = passwordCtrl.text.trim();

              // لو كتب email لازم يكتب pass
              if (email.isNotEmpty && pass.isEmpty) {
                showError('Password is required'.tr);
                return;
              }

              controller.create({
                'name': name,
                'description': descCtrl.text.trim(),
                if (email.isNotEmpty) 'adminEmail': email,
                if (pass.isNotEmpty) 'adminPassword': pass,
              });

              Get.back();
            },
            child: Text(
              'Save'.tr,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
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
    String? selectedRole;

    // Build roles list from controller
    final roleNames =
        controller.roles
            .map((r) => (r['name'] ?? '').toString())
            .where((n) => n.trim().isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Add admin'.tr,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            ),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 460,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(
                      controller: nameCtrl,
                      label: 'Name'.tr,
                      hint: 'Admin name'.tr,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: emailCtrl,
                      label: 'Email'.tr,
                      hint: 'example@mail.com'.tr,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      controller: passwordCtrl,
                      label: 'Password'.tr,
                      hint: '••••••••'.tr,
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 10),

                    // Role dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      items: roleNames
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: TextStyle(color: AppColors.text),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedRole = v),
                      decoration: InputDecoration(
                        labelText: 'Role'.tr,
                        prefixIcon: Icon(
                          Icons.verified_user_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                      dropdownColor: AppColors.card,
                      style: TextStyle(color: AppColors.text),
                    ),

                    if (roleNames.isEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'No roles found. Create a role first.'.tr,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: Get.back,
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  final pass = passwordCtrl.text.trim();
                  final role = (selectedRole ?? '').trim();

                  if (name.isEmpty ||
                      email.isEmpty ||
                      pass.isEmpty ||
                      role.isEmpty) {
                    showError('Please fill required fields'.tr);
                    return;
                  }

                  await controller.createAdmin(
                    name: name,
                    email: email,
                    password: pass,
                    role: role,
                  );

                  Get.back();
                },
                child: Text(
                  'Save'.tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    RolesController controller,
    String roleId,
    String roleName,
  ) {
    if (roleId.trim().isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: Text(
          '${'Delete this role?'.tr}\n${roleName.isEmpty ? '' : roleName}',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteRole(roleId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RoleAction { edit, delete }
