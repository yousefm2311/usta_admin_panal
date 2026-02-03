import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';
import 'package:usta_admin_panal/core/utils/notify.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/coupons_controller.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponsController());
    return AdminLayout(
      title: ''.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Coupons manager'.tr,
                style:  TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openDialog(controller),
                icon:  Icon(Icons.add, color: AppColors.primary),
                label: Text(
                  'Add'.tr,
                  style:  TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const ListLoading(itemHeight: 55);
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
            if (controller.coupons.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'No data'.tr,
                  style:  TextStyle(color: AppColors.textMuted),
                ),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Code'.tr)),
                  DataColumn(label: Text('Discount'.tr)),
                  DataColumn(label: Text('Usage'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('expiry'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.coupons
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text((c['code'] ?? '').toString())),
                          DataCell(Text((c['value'] ?? '').toString())),
                          DataCell(Text((c['usage'] ?? '').toString())),
                          DataCell(
                            _statusChip(
                              (c['active'] ?? true) ? 'Active'.toString() : 'Inactive'.toString(),
                            ),
                          ),
                          DataCell(
                            Text((formatDateString(c['expiresAt'].toString()))),
                          ),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    final id = (c['_id'] ?? c['id']).toString();
                                    final newStatus = !(c['active'] ?? true);
                                    controller.update_(id, {
                                      "active": newStatus,
                                    });
                                    c['active'] = newStatus;
                                  },
                                  child: Text(
                                    (c['active'] ?? true)
                                        ? 'Deactivate'.tr
                                        : 'Activate'.tr,
                                    style: TextStyle(
                                      color: (c['active'] ?? true)
                                          ? Colors.redAccent
                                          : AppColors.success,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      _openDialog(controller, coupon: c),
                                  child: Text('Edit'.tr),
                                ),
                                TextButton(
                                  onPressed: () => controller.delete(
                                    (c['_id'] ?? c['id'] ?? '').toString(),
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
            );
          }),
        ],
      ),
    );
  }

  void _openDialog(
    CouponsController controller, {
    Map<String, dynamic>? coupon,
  }) {
    final code = TextEditingController(text: coupon?['code']?.toString() ?? '');
    final value = TextEditingController(
      text: coupon?['value']?.toString() ?? '',
    );
    final discountType = TextEditingController(
      text: coupon?['discountType']?.toString() ?? 'percent',
    );
    final minOrder = TextEditingController(
      text: coupon?['minOrder']?.toString() ?? '',
    );
    final expiresAt = TextEditingController(
      text: coupon?['expiresAt']?.toString() ?? '',
    );
    DateTime? expiryDate;
    final expiresValue = coupon?['expiresAt'];
    if (expiresValue != null && expiresValue.toString().isNotEmpty) {
      expiryDate = DateTime.tryParse(expiresValue.toString());
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          coupon == null ? 'Add coupon'.tr : 'Edit coupon'.tr,
          style:  TextStyle(color: AppColors.text),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: code,
                  decoration: InputDecoration(labelText: 'Code'.tr),
                  style:  TextStyle(color: AppColors.text),
                ),
                TextField(
                  controller: value,
                  decoration: InputDecoration(labelText: 'Value'.tr),
                  style:  TextStyle(color: AppColors.text),
                ),
                TextField(
                  controller: discountType,
                  decoration: InputDecoration(
                    labelText: 'Discount type (percent/fixed)'.tr,
                  ),
                  style:  TextStyle(color: AppColors.text),
                ),
                TextField(
                  controller: minOrder,
                  decoration: InputDecoration(labelText: 'Min order'.tr),
                  style:  TextStyle(color: AppColors.text),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expiryDate != null
                            ? formatDate(expiryDate!)
                            : 'No expiry selected'.tr,
                        style:  TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final context = Get.context;
                        if (context == null) return;
                        final now = DateTime.now();
                        final minDate = now.subtract(const Duration(days: 1));
                        final init = expiryDate ?? now;
                        final safeInitialDate = init.isBefore(minDate)
                            ? minDate
                            : init;
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: safeInitialDate,
                          firstDate: minDate,
                          lastDate: now.add(const Duration(days: 365 * 3)),
                        );
                        if (picked != null) {
                          setState(() {
                            expiryDate = picked;
                          });
                          final formatted = formatDate(picked);
                          expiresAt.text = formatted;
                          // تم
                        }
                      },
                      child: Text('Pick expiry'.tr),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Cancel'.tr,
              style:  TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              if (code.text.trim().isEmpty || value.text.trim().isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }
              final payload = {
                'code': code.text.trim(),
                'value':
                    double.tryParse(value.text.trim()) ?? value.text.trim(),
                'discountType': discountType.text.trim(),
                'minOrder': minOrder.text.trim(),
                'expiresAt': expiresAt.text.trim(),
                "active": coupon == null ? true : (coupon['active'] ?? true),
              };
              if (coupon == null) {
                controller.create(payload);
              } else {
                controller.update_(
                  (coupon['_id'] ?? coupon['id'] ?? '').toString(),
                  payload,
                );
              }
              Get.back();
            },
            child: Text(
              'Save'.tr,
              style:  TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = AppColors.success;
        break;
      case 'inactive':
        color = AppColors.danger;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
