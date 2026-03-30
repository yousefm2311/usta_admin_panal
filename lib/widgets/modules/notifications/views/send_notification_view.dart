import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../primary_button.dart';
import '../controllers/notifications_controller.dart';

class SendNotificationView extends StatefulWidget {
  const SendNotificationView({super.key});

  @override
  State<SendNotificationView> createState() => _SendNotificationViewState();
}

class _SendNotificationViewState extends State<SendNotificationView> {
  String target = 'All';
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return AdminLayout(
      title: 'Send notification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create notification'.tr,
            style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target audience'.tr, style:  TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.sm,
                    children: ['All', 'Customers', 'Artisans']
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item.tr),
                            selected: target == item,
                            onSelected: (_) => setState(() => target = item),
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.card,
                            labelStyle: TextStyle(
                              color: target == item ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _titleController,
                    style:  TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'Title'.tr),
                    validator: (v) => (v == null || v.isEmpty) ? 'Title'.tr : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _messageController,
                    style:  TextStyle(color: AppColors.text),
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Message'.tr,
                      hintText: 'Type notification message'.tr,
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Message'.tr : null,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Obx(
                    () => PrimaryButton(
                      expand: true,
                      label: 'Send notification'.tr,
                      loadingLabel: 'Loading'.tr,
                      isLoading: controller.sending.value,
                      icon: Icons.send,
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          controller.send(
                            title: _titleController.text.trim(),
                            message: _messageController.text.trim(),
                            target: target,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
