import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/notify.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/notifications_controller.dart';

class NotificationsCenterView extends StatefulWidget {
  const NotificationsCenterView({super.key});

  @override
  State<NotificationsCenterView> createState() =>
      _NotificationsCenterViewState();
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
      title: '',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              title: 'Notifications',
              subtitle:
                  'Manage templates, send broadcasts, and monitor notification history from one workspace.',
              actions: [
                IconButton(
                  onPressed: controller.loadHistory,
                  icon: Icon(Icons.refresh, color: AppColors.textMuted),
                  tooltip: 'Refresh'.tr,
                ),
              ],
              badges: [
                AdminInfoBadge(
                  icon: Icons.campaign_outlined,
                  label: 'Broadcast center',
                ),
                AdminInfoBadge(
                  icon: Icons.note_alt_outlined,
                  label: 'Templates ready',
                  color: AppColors.success,
                ),
                AdminInfoBadge(
                  icon: Icons.history_rounded,
                  label: 'History stream',
                  color: Colors.orange.shade700,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth >= 1100
                    ? (constraints.maxWidth - AppSizes.md * 2) / 3
                    : constraints.maxWidth >= 720
                    ? (constraints.maxWidth - AppSizes.md) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.md,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Templates',
                        value: controller.templates.length.toString(),
                        subtitle: 'Templates ready',
                        icon: Icons.note_alt_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Sent notifications',
                        value: controller.history.length.toString(),
                        subtitle: 'History stream',
                        icon: Icons.notifications_active_outlined,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Status overview',
                        value: controller.sending.value
                            ? 'Sending'.tr
                            : 'Ready'.tr,
                        subtitle: 'All notifications in one place',
                        icon: Icons.published_with_changes_outlined,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Send notification',
              subtitle: 'Broadcast center',
              icon: Icons.send_outlined,
              child: _sendCard(controller),
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Notification Templates',
              subtitle: 'Template library',
              icon: Icons.note_alt_outlined,
              actions: [
                TextButton.icon(
                  onPressed: () => _openTemplateDialog(controller),
                  icon: Icon(Icons.add, color: AppColors.primary),
                  label: Text(
                    'Add'.tr,
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
              child: _templatesTable(controller),
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Sent notifications',
              subtitle: 'Recent activity',
              icon: Icons.history_rounded,
              child: _historyList(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendCard(NotificationsController controller) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target'.tr, style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: AppSizes.xs),
          Wrap(
            spacing: AppSizes.sm,
            children: ['all', 'customers', 'artisans']
                .map(
                  (t) => ChoiceChip(
                    label: Text(_targetLabel(t).tr),
                    selected: target == t,
                    onSelected: (_) => setState(() => target = t),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      color: target == t ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'.tr),
            style: TextStyle(color: AppColors.text),
            validator: (v) => (v == null || v.isEmpty) ? 'Title'.tr : null,
          ),
          const SizedBox(height: AppSizes.md),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Message'.tr,
              hintText: 'Type notification message'.tr,
            ),
            style: TextStyle(color: AppColors.text),
            maxLines: 4,
            validator: (v) => (v == null || v.isEmpty) ? 'Message'.tr : null,
          ),
          const SizedBox(height: AppSizes.md),
          SizedBox(
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
              label: Text(
                controller.sending.value
                    ? 'Loading'.tr
                    : 'Send notification'.tr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _templatesTable(NotificationsController controller) {
    return Obx(() {
      if (controller.templates.isEmpty) {
        return Text(
          'No templates'.tr,
          style: TextStyle(color: AppColors.textMuted),
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
                    DataCell(
                      Text((formatDateString(t['updatedAt'])).toString()),
                    ),
                    DataCell(
                      Row(
                        children: [
                          TextButton(
                            onPressed: () =>
                                _openTemplateDialog(controller, template: t),
                            child: Text('Edit'.tr),
                          ),
                          TextButton(
                            onPressed: () => controller.deleteTemplate(
                              (t['_id'] ?? t['id'] ?? '').toString(),
                            ),
                            child: Text(
                              'Delete'.tr,
                              style: const TextStyle(color: Colors.redAccent),
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
    });
  }

  Widget _historyList(NotificationsController controller) {
    return Obx(() {
      if (controller.loading.value && controller.history.isEmpty) {
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
      if (controller.history.isEmpty) {
        return Text('No data'.tr, style: TextStyle(color: AppColors.textMuted));
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
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none, color: AppColors.primary),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (n['title'] ?? '').toString(),
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            (n['body'] ?? n['message'] ?? '').toString(),
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                          Text(
                            (n['target'] ?? '').toString().tr,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDate(n['date'] ?? n['createdAt']),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete'.tr,
                      onPressed: () => controller.deleteNotification(
                        (n['_id'] ?? n['id'] ?? '').toString(),
                      ),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      );
    });
  }

  void _openTemplateDialog(
    NotificationsController controller, {
    Map<String, dynamic>? template,
  }) {
    final name = TextEditingController(
      text: template?['name']?.toString() ?? '',
    );
    final target = RxString(
      (template?['target']?.toString() ?? 'customers').toLowerCase(),
    );
    final title = TextEditingController(
      text: template?['title']?.toString() ?? '',
    );
    final message = TextEditingController(
      text: template?['message']?.toString() ?? '',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          template == null ? 'Add'.tr : 'Edit'.tr,
          style: TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(labelText: 'Name'.tr),
              style: TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Target'.tr,
                style: TextStyle(color: AppColors.textMuted),
              ),
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
                        labelStyle: TextStyle(
                          color: target.value == t
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            TextField(
              controller: title,
              decoration: InputDecoration(labelText: 'Title'.tr),
              style: TextStyle(color: AppColors.text),
            ),
            TextField(
              controller: message,
              decoration: InputDecoration(labelText: 'Message'.tr),
              style: TextStyle(color: AppColors.text),
              maxLines: 3,
            ),
          ],
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
              if (name.text.trim().isEmpty ||
                  title.text.trim().isEmpty ||
                  message.text.trim().isEmpty) {
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
                controller.updateTemplate(
                  (template['_id'] ?? template['id'] ?? '').toString(),
                  payload,
                );
              }
              Get.back();
            },
            child: Text('Save'.tr, style: TextStyle(color: AppColors.primary)),
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

  String _targetLabel(String value) {
    switch (value) {
      case 'customers':
        return 'Customers';
      case 'artisans':
        return 'Artisans';
      default:
        return 'All';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
