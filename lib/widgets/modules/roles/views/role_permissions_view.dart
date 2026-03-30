import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/role_permissions_controller.dart';

class RolePermissionsView extends StatefulWidget {
  const RolePermissionsView({super.key});

  @override
  State<RolePermissionsView> createState() => _RolePermissionsViewState();
}

class _RolePermissionsViewState extends State<RolePermissionsView> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _loaded = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final roleId = (args?['_id'] ?? args?['id'] ?? '').toString();
    final roleName = (args?['name'] ?? args?['role'] ?? '').toString();

    final controller = Get.put(RolePermissionsController());

    // مهم: ما تعملش load جوه build كل مرة
    if (!_loaded && roleId.isNotEmpty) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.load(roleId);
      });
    }

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(lines: 24);
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

        final permissions = controller.permissions;
        final filtered = _filterPermissions(permissions, _query);

        return Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _header(
                roleName: roleName,
                modulesCount: permissions.length,
                onSelectAll: () => _setAll(controller, permissions, true),
                onClearAll: () => _setAll(controller, permissions, false),
              ),
              const SizedBox(height: AppSizes.md),

              // Search
              _searchBar(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),

              const SizedBox(height: AppSizes.md),

              // Content
              if (permissions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'No permissions'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'No results'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              else
                ...filtered.asMap().entries.map((entry) {
                  // NOTE:
                  // filtered list index != original list index
                  // لازم نجيب index الحقيقي في controller.permissions
                  final module = entry.value;
                  final realIndex = _indexOfModule(permissions, module);
                  if (realIndex == -1) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: _moduleCard(
                      moduleName: (module['module'] ?? '').toString(),
                      read: module['read'] == true,
                      create: module['create'] == true,
                      update: module['update'] == true,
                      delete: module['delete'] == true,
                      onToggleAll: () =>
                          _toggleAllModule(controller, realIndex, module),
                      onToggle: (key) => controller.toggle(realIndex, key),
                    ),
                  );
                }),

              const SizedBox(height: AppSizes.md),

              // Footer Save
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: controller.save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text('Save'.tr),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // =========================
  // UI Pieces
  // =========================

  Widget _header({
    required String roleName,
    required int modulesCount,
    required VoidCallback onSelectAll,
    required VoidCallback onClearAll,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign permissions'.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (roleName.trim().isNotEmpty)
                    _pill('${'Role'.tr}: $roleName'),
                  _pill('${'Modules'.tr}: $modulesCount'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        TextButton(onPressed: onSelectAll, child: Text('Select all'.tr)),
        TextButton(
          onPressed: onClearAll,
          child: Text(
            'Clear all'.tr,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _pill(String text) {
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

  Widget _searchBar({
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required VoidCallback onClear,
  }) {
    return SizedBox(
      width: 420,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          hintText: 'Search modules'.tr,
          hintStyle: TextStyle(color: AppColors.textMuted),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close, color: AppColors.textMuted),
                ),
        ),
        style: TextStyle(color: AppColors.text),
      ),
    );
  }

  Widget _moduleCard({
    required String moduleName,
    required bool read,
    required bool create,
    required bool update,
    required bool delete,
    required VoidCallback onToggleAll,
    required void Function(String key) onToggle,
  }) {
    final moduleLabel = moduleName.isEmpty ? '-' : moduleName.tr;

    final allOn = read && create && update && delete;
    final anyOn = read || create || update || delete;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: anyOn
              ? AppColors.primary.withOpacity(0.35)
              : AppColors.border.withOpacity(0.9),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  moduleLabel,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                allOn
                    ? 'All'.tr
                    : anyOn
                    ? 'Custom'.tr
                    : 'None'.tr,
                style: TextStyle(
                  color: allOn
                      ? AppColors.success
                      : anyOn
                      ? AppColors.primary
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onToggleAll,
                child: Text(allOn ? 'Clear'.tr : 'All'.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _permChip('Read', read, () => onToggle('read')),
              _permChip('Create', create, () => onToggle('create')),
              _permChip('Update', update, () => onToggle('update')),
              _permChip('Delete', delete, () => onToggle('delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permChip(String label, bool selected, VoidCallback onTap) {
    final color = selected ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.14)
              : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary.withOpacity(0.55)
                : AppColors.border.withOpacity(0.9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              label.tr,
              style: TextStyle(
                color: selected ? AppColors.text : AppColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Logic helpers
  // =========================

  List<Map<String, dynamic>> _filterPermissions(List<dynamic> list, String q) {
    final query = q.trim().toLowerCase();
    final normalized = list
        .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
        .toList();

    if (query.isEmpty) return normalized;

    return normalized.where((m) {
      final name = (m['module'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  int _indexOfModule(List<dynamic> list, Map<String, dynamic> module) {
    final moduleName = (module['module'] ?? '').toString();
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (m is Map) {
        final name = (m['module'] ?? '').toString();
        if (name == moduleName) return i;
      }
    }
    return -1;
  }

  void _toggleAllModule(
    RolePermissionsController controller,
    int index,
    Map<String, dynamic> module,
  ) {
    final read = module['read'] == true;
    final create = module['create'] == true;
    final update = module['update'] == true;
    final delete = module['delete'] == true;

    final allOn = read && create && update && delete;

    // لو كله On اقفل كله، غير كده افتح كله
    final target = !allOn;

    // هنستخدم toggle المتاح عندك (بدون تعديل controller)
    // نخليها توصل للحالة المطلوبة.
    if ((module['read'] == true) != target) controller.toggle(index, 'read');
    if ((module['create'] == true) != target)
      controller.toggle(index, 'create');
    if ((module['update'] == true) != target)
      controller.toggle(index, 'update');
    if ((module['delete'] == true) != target)
      controller.toggle(index, 'delete');
  }

  void _setAll(
    RolePermissionsController controller,
    List<dynamic> list,
    bool value,
  ) {
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (m is! Map) continue;

      if ((m['read'] == true) != value) controller.toggle(i, 'read');
      if ((m['create'] == true) != value) controller.toggle(i, 'create');
      if ((m['update'] == true) != value) controller.toggle(i, 'update');
      if ((m['delete'] == true) != value) controller.toggle(i, 'delete');
    }
  }
}
