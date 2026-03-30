import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/utils/notify.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../table_wrapper.dart';
import '../controllers/notifications_controller.dart';
import '../../../shimmer_widgets.dart';

class NotificationTemplatesView extends StatelessWidget {
  const NotificationTemplatesView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    return AdminLayout(
      title: 'Notification Templates'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Templates'.tr, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _openTemplateDialog(controller),
                icon:  Icon(Icons.add, color: AppColors.primary),
                label: Text('Add', style:  TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.templates.isEmpty && controller.loading.value) {
              return const ListLoading();
            }
            if (controller.templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Name'.tr)),
                  DataColumn(label: Text('Target'.tr)),
                  DataColumn(label: Text('Updated'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.templates
                    .map(
                      (t) => DataRow(cells: [
                        DataCell(Text((t['name'] ?? '').toString())),
                        DataCell(Text((t['target'] ?? '').toString())),
                        DataCell(Text((t['updatedAt'] ?? '').toString())),
                        DataCell(
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _openTemplateDialog(controller, template: t),
                                child: Text('Edit'.tr),
                              ),
                              TextButton(
                                onPressed: () => controller.deleteTemplate((t['_id'] ?? t['id'] ?? '').toString()),
                                child: Text('Delete'.tr, style: const TextStyle(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    )
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _openTemplateDialog(NotificationsController controller, {Map<String, dynamic>? template}) {
    final name = TextEditingController(text: template?['name']?.toString() ?? '');
    final target = RxString((template?['target']?.toString() ?? 'customers').toLowerCase());
    final title = TextEditingController(text: template?['title']?.toString() ?? '');
    final message = TextEditingController(text: template?['message']?.toString() ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(template == null ? 'Add' : 'Edit', style:  TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              style:  TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Target', style:  TextStyle(color: AppColors.textMuted)),
            ),
            Obx(
              () => Wrap(
                spacing: AppSizes.sm,
                children: ['all', 'customers', 'artisans']
                    .map(
                      (t) => ChoiceChip(
                        label: Text(t.tr),
                        selected: target.value == t,
                        onSelected: (_) => target.value = t,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(color: target.value == t ? Colors.white : AppColors.textMuted),
                      ),
                    )
                    .toList(),
              ),
            ),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
              style:  TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: message,
              decoration: const InputDecoration(labelText: 'Message'),
              style:  TextStyle(color: AppColors.text),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel'.tr, style:  TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (name.text.trim().isEmpty || title.text.trim().isEmpty || message.text.trim().isEmpty) {
                showError('Please fill required fields'.tr);
                return;
              }
              final payload = {
                'name': name.text.trim(),
                'target': target.value,
                'title': title.text.trim(),
                'message': message.text.trim(),
              };
              if (template == null) {
                controller.createTemplate(payload);
              } else {
                controller.updateTemplate((template['_id'] ?? template['id'] ?? '').toString(), payload);
              }
              Get.back();
            },
            child: Text('Save'.tr, style:  TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}


