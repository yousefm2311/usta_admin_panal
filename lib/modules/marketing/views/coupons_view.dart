import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/utils/notify.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/coupons_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class CouponsView extends StatelessWidget {
  const CouponsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CouponsController());
    return AdminLayout(
      title: 'Coupons'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Coupons manager'.tr,
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openDialog(controller),
                icon: const Icon(Icons.add, color: AppColors.primary),
                label: Text('Add', style: const TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const ListLoading();
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            if (controller.coupons.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Code'.tr)),
                  DataColumn(label: Text('Discount'.tr)),
                  DataColumn(label: Text('Usage'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.coupons
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text((c['code'] ?? '').toString())),
                          DataCell(Text((c['value'] ?? '').toString())),
                          DataCell(Text((c['usage'] ?? '').toString())),
                          DataCell(Text((c['active'] ?? true) ? 'Active'.tr : 'Inactive'.tr)),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => _openDialog(controller, coupon: c),
                                  child: Text('Edit'.tr),
                                ),
                                TextButton(
                                  onPressed: () => controller.delete((c['_id'] ?? c['id'] ?? '').toString()),
                                  child: Text('Delete'.tr, style: const TextStyle(color: Colors.redAccent)),
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

  void _openDialog(CouponsController controller, {Map<String, dynamic>? coupon}) {
    final code = TextEditingController(text: coupon?['code']?.toString() ?? '');
    final value = TextEditingController(text: coupon?['value']?.toString() ?? '');
    final discountType = TextEditingController(text: coupon?['discountType']?.toString() ?? 'percent');
    final minOrder = TextEditingController(text: coupon?['minOrder']?.toString() ?? '');
    final expiresAt = TextEditingController(text: coupon?['expiresAt']?.toString() ?? '');
    DateTime? expiryDate;
    final expiresValue = coupon?['expiresAt'];
    if (expiresValue != null && expiresValue.toString().isNotEmpty) {
      expiryDate = DateTime.tryParse(expiresValue.toString());
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(coupon == null ? 'Add coupon' : 'Edit coupon', style: const TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: code,
              decoration: const InputDecoration(labelText: 'Code'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: value,
              decoration: const InputDecoration(labelText: 'Value'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: discountType,
              decoration: const InputDecoration(labelText: 'Discount type (percent/fixed)'),
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: minOrder,
              decoration: const InputDecoration(labelText: 'Min order'),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    expiryDate != null ? expiryDate.toString().split('.').first : 'No expiry selected'.tr,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final currentContext = Get.context;
                    if (currentContext == null) return;
                    final picked = await showDatePicker(
                      context: currentContext,
                      initialDate: (expiryDate ?? DateTime.now()),
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      expiryDate = picked;
                      expiresAt.text = picked.toIso8601String();
                    }
                  },
                  child: Text('Pick expiry'.tr),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('Cancel'.tr, style: const TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              if (code.text.trim().isEmpty || value.text.trim().isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }
              final payload = {
                'code': code.text.trim(),
                'value': double.tryParse(value.text.trim()) ?? value.text.trim(),
                'discountType': discountType.text.trim(),
                'minOrder': minOrder.text.trim(),
                'expiresAt': expiresAt.text.trim(),
              };
              if (coupon == null) {
                controller.create(payload);
              } else {
                controller.update_((coupon['_id'] ?? coupon['id'] ?? '').toString(), payload);
              }
              Get.back();
            },
            child: Text('Save'.tr, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}


