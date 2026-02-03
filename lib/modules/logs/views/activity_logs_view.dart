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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityLogsController());

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(lines: 30,);
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

        if (controller.logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style:  TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity logs'.tr,
              style:  TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSizes.md),

            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('User'.tr)),
                  DataColumn(label: Text('Action'.tr)),
                  DataColumn(label: Text('Module'.tr)),
                  DataColumn(label: Text('Time'.tr)),
                ],
                rows: controller.logs.map((l) {
                  final actor = l['actor'];
                  final actionCode = l['action'] ?? '';
                  final moduleCode = l['entity'] ?? '';
                  final time = formatDateTime(l['createdAt'] ?? '');

                  return DataRow(
                    cells: [
                      /// USER
                      DataCell(Text(getActorName(actor))),

                      /// ACTION + ICON + COLOR
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              actionIcon(actionCode),
                              color: actionColor(actionCode),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              trAction(actionCode),
                              style: TextStyle(
                                color: actionColor(actionCode),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// MODULE (Translated)
                      DataCell(Text(trModule(moduleCode.toString()))),

                      /// TIME
                      DataCell(Text(time)),
                    ],
                  );
                }).toList(),
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
    if (actor == null) return 'Unknown';
    return actor['name']?.toString() ?? 'Unknown';
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
        return Colors.green;

      case 'role_update':
      case 'coupon_update':
        return Colors.orange;

      case 'role_delete':
      case 'coupon_delete':
        return Colors.red;

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
