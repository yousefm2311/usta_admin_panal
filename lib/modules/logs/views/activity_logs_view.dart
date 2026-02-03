import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/activity_logs_controller.dart';

class ActivityLogsView extends StatelessWidget {
  ActivityLogsView({super.key});

  final _q = ''.obs; // search query local

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityLogsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color surface() => AppColors.card;
    Color border() => AppColors.border;

    return AdminLayout(
      title: 'Activity logs'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(lines: 18);
        }

        if (controller.error.value != null) {
          return _StateBox(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong'.tr,
            subtitle: controller.error.value!,
            onRetry: () {
              // لو عندك load/refresh
              // controller.load();
            },
          );
        }

        if (controller.logs.isEmpty) {
          return _StateBox(
            icon: Icons.history_rounded,
            title: 'No data'.tr,
            subtitle: 'No activity yet'.tr,
          );
        }

        // ✅ فلترة محلية على UI فقط (بدون ما نغيّر controller)
        final logs = controller.logs.where((l) {
          final q = _q.value.trim().toLowerCase();
          if (q.isEmpty) return true;

          final actorName = getActorName(l['actor']).toLowerCase();
          final actionCode = (l['action'] ?? '').toString().toLowerCase();
          final moduleCode = (l['entity'] ?? '').toString().toLowerCase();

          return actorName.contains(q) ||
              actionCode.contains(q) ||
              moduleCode.contains(q);
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // Header
            // =========================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Activity logs'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Total'.tr}: ${controller.logs.length} • ${'Showing'.tr}: ${logs.length}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh'.tr,
                  onTap: () {
                    // controller.load();
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // Search
            // =========================
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: surface(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border()),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: AppColors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => _q.value = v,
                      decoration: InputDecoration(
                        hintText: 'Search by user, action, module...'.tr,
                        hintStyle: TextStyle(color: AppColors.textMuted),
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_q.value.isNotEmpty)
                    InkWell(
                      onTap: () => _q.value = '',
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // Table
            // =========================
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: surface(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border()),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TableWrapper(
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 44,
                  dataRowMinHeight: 50,
                  dataRowMaxHeight: 62,
                  columnSpacing: 18,
                  horizontalMargin: 12,
                  dividerThickness: 0.7,
                  headingTextStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                  dataTextStyle: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  columns: [
                    DataColumn(label: _Head('User'.tr)),
                    DataColumn(label: _Head('Action'.tr)),
                    DataColumn(label: _Head('Module'.tr)),
                    DataColumn(label: _Head('Time'.tr)),
                  ],
                  rows: List.generate(logs.length, (i) {
                    final l = logs[i] as Map<String, dynamic>;
                    final actor = l['actor'];
                    final actionCode = (l['action'] ?? '').toString();
                    final moduleCode = (l['entity'] ?? '').toString();
                    final createdAt = (l['createdAt'] ?? '').toString();

                    final time = formatDateTime(createdAt);
                    final zebra = i.isEven
                        ? (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC))
                        : surface();

                    return DataRow(
                      onSelectChanged: (_) {},
                      cells: [
                        // USER
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Row(
                              children: [
                                _AvatarLetter(text: getActorName(actor)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    getActorName(actor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ACTION (Chip)
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: _Chip(
                              icon: actionIcon(actionCode),
                              text: trAction(actionCode),
                              fg: actionColor(actionCode),
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // MODULE (Chip)
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: _Chip(
                              icon: Icons.layers_outlined,
                              text: trModule(moduleCode),
                              fg: AppColors.primary,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // TIME
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Text(
                              time,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // =========================================================
  // USER NAME
  // =========================================================
  String getActorName(dynamic actor) {
    if (actor == null) return 'Unknown'.tr;
    if (actor is Map<String, dynamic>) {
      return actor['name']?.toString() ??
          actor['fullName']?.toString() ??
          actor['email']?.toString() ??
          'Unknown'.tr;
    }
    return actor.toString();
  }

  // =========================================================
  // DATE FORMAT
  // =========================================================
  String formatDateTime(String date) {
    final d = DateTime.tryParse(date);
    if (d == null) return date;

    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  // =========================================================
  // ACTION COLORS
  // =========================================================
  Color actionColor(String action) {
    switch (action) {
      case 'role_create':
      case 'coupon_create':
        return const Color(0xFF16A34A); // green

      case 'role_update':
      case 'coupon_update':
        return const Color(0xFFF59E0B); // amber

      case 'role_delete':
      case 'coupon_delete':
        return const Color(0xFFDC2626); // red

      default:
        return AppColors.textMuted;
    }
  }

  // =========================================================
  // ACTION ICONS
  // =========================================================
  IconData actionIcon(String action) {
    switch (action) {
      case 'role_create':
        return Icons.add_circle;

      case 'role_update':
        return Icons.edit;

      case 'role_delete':
        return Icons.delete;

      case 'coupon_create':
        return Icons.local_offer;

      case 'coupon_update':
        return Icons.local_offer_outlined;

      case 'coupon_delete':
        return Icons.local_offer_rounded;

      default:
        return Icons.info;
    }
  }

  // =========================================================
  // TRANSLATION MAPS (EN + AR)
  // =========================================================

  final Map<String, Map<String, String>> actionTranslations = {
    "role_create": {"en": "Role Created", "ar": "إنشاء صلاحية"},
    "role_update": {"en": "Role Updated", "ar": "تعديل صلاحية"},
    "role_delete": {"en": "Role Deleted", "ar": "حذف صلاحية"},
    "coupon_create": {"en": "Coupon Created", "ar": "إنشاء كوبون"},
    "coupon_update": {"en": "Coupon Updated", "ar": "تعديل كوبون"},
    "coupon_delete": {"en": "Coupon Deleted", "ar": "حذف كوبون"},
  };

  final Map<String, Map<String, String>> moduleTranslations = {
    "role": {"en": "Role", "ar": "الصلاحيات"},
    "coupon": {"en": "Coupon", "ar": "الكوبونات"},
    "dashboard": {"en": "Dashboard", "ar": "لوحة التحكم"},
    "orders": {"en": "Orders", "ar": "الطلبات"},
    "customers": {"en": "Customers", "ar": "العملاء"},
    "artisans": {"en": "Artisans", "ar": "الحرفيين"},
    "requests": {"en": "Requests", "ar": "الطلبات الجديدة"},
    "payments": {"en": "Payments", "ar": "المدفوعات"},
    "notifications": {"en": "Notifications", "ar": "الإشعارات"},
    "categories": {"en": "Categories", "ar": "التصنيفات"},
  };

  // =========================================================
  // ACTION TRANSLATOR
  // =========================================================
  String trAction(String action) {
    final lang = Get.locale?.languageCode ?? 'en';
    return actionTranslations[action]?[lang] ?? action;
  }

  // =========================================================
  // MODULE TRANSLATOR
  // =========================================================
  String trModule(String module) {
    final lang = Get.locale?.languageCode ?? 'en';
    return moduleTranslations[module]?[lang] ?? module;
  }
}

// =========================
// UI bits
// =========================

class _Head extends StatelessWidget {
  final String text;
  const _Head(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class _ZebraCell extends StatelessWidget {
  final Color zebra;
  final Widget child;
  const _ZebraCell({required this.zebra, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: child,
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color fg;
  final bool isDark;
  const _Chip({
    required this.icon,
    required this.text,
    required this.fg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bg = fg.withOpacity(isDark ? 0.18 : 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  final String text;
  const _AvatarLetter({required this.text});

  @override
  Widget build(BuildContext context) {
    final t = text.trim();
    final letter = t.isEmpty ? '?' : t[0].toUpperCase();

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        letter,
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.text),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _StateBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSizes.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}
