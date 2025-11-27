import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/notifications_controller.dart';

class NotificationsCenterView extends StatefulWidget {
  const NotificationsCenterView({super.key});

  @override
  State<NotificationsCenterView> createState() => _NotificationsCenterViewState();
}

class _NotificationsCenterViewState extends State<NotificationsCenterView> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String target = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return AdminLayout(
      title: 'Notifications',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Send notification
            Text('Send Notification'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppSizes.sm),
            _sendCard(controller),
            const SizedBox(height: AppSizes.md),
            // Templates section
            Row(
              children: [
                Text('Notification Templates'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openTemplateDialog(controller),
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: Text('Add'.tr, style: const TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            _templatesTable(controller),
            const SizedBox(height: AppSizes.md),
            // Notifications list
            Row(
              children: [
                Text(
                  'Sent notifications'.tr,
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: controller.loadHistory,
                  icon: const Icon(Icons.refresh, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            _historyList(controller),
          ],
        ),
      ),
    );
  }

  Widget _sendCard(NotificationsController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Target'.tr, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: AppSizes.xs),
            Wrap(
              spacing: AppSizes.sm,
              children: ['all', 'customers', 'artisans']
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t.tr),
                      selected: target == t,
                      onSelected: (_) => setState(() => target = t),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.card,
                      labelStyle: TextStyle(color: target == t ? Colors.white : AppColors.textMuted),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'.tr),
              style: const TextStyle(color: AppColors.text),
              validator: (v) => (v == null || v.isEmpty) ? 'Title'.tr : null,
            ),
            const SizedBox(height: AppSizes.md),
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Message'.tr, hintText: 'Type notification message'.tr),
              style: const TextStyle(color: AppColors.text),
              maxLines: 4,
              validator: (v) => (v == null || v.isEmpty) ? 'Message'.tr : null,
            ),
            const SizedBox(height: AppSizes.md),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  onPressed: controller.sending.value
                      ? null
                      : () {
                          if (!(_formKey.currentState?.validate() ?? false)) return;
                          controller.send(
                            title: _titleController.text.trim(),
                            message: _messageController.text.trim(),
                            target: target,
                          );
                        },
                  label: Text(controller.sending.value ? 'Loading'.tr : 'Send notification'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _templatesTable(NotificationsController controller) {
    return Obx(() {
      if (controller.templates.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text('No templates'.tr, style: const TextStyle(color: AppColors.textMuted)),
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
                (t) => DataRow(
                  cells: [
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
                  ],
                ),
              )
              .toList(),
        ),
      );
    });
  }

  Widget _historyList(NotificationsController controller) {
    return Obx(() {
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
      if (controller.history.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
        );
      }
      return Column(
        children: controller.history
            .map(
              (n) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSizes.sm),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_none, color: AppColors.primary),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (n['title'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            (n['body'] ?? n['message'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                          Text(
                            (n['target'] ?? '').toString().tr,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(n['date'] ?? n['createdAt']),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                    IconButton(
                      tooltip: 'Delete'.tr,
                      onPressed: () => controller.deleteNotification((n['_id'] ?? n['id'] ?? '').toString()),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    });
  }

  void _openTemplateDialog(NotificationsController controller, {Map<String, dynamic>? template}) {
    final name = TextEditingController(text: template?['name']?.toString() ?? '');
    final target = RxString((template?['target']?.toString() ?? 'customers').toLowerCase());
    final title = TextEditingController(text: template?['title']?.toString() ?? '');
    final message = TextEditingController(text: template?['message']?.toString() ?? '');

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(template == null ? 'Add'.tr : 'Edit'.tr, style: const TextStyle(color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Target'.tr, style: const TextStyle(color: AppColors.textMuted)),
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
              style: const TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: message,
              decoration: const InputDecoration(labelText: 'Message'),
              style: const TextStyle(color: AppColors.text),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('Cancel'.tr, style: const TextStyle(color: AppColors.textMuted)),
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
            child: Text('Save'.tr, style: const TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
