import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';
import '../controllers/notifications_broadcast_controller.dart';

class NotificationsBroadcastView extends StatefulWidget {
  const NotificationsBroadcastView({super.key});

  @override
  State<NotificationsBroadcastView> createState() => _NotificationsBroadcastViewState();
}

class _NotificationsBroadcastViewState extends State<NotificationsBroadcastView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _topicController = TextEditingController();
  final _customerIdsController = TextEditingController();
  final _artisanIdsController = TextEditingController();
  final _adminIdsController = TextEditingController();
  String _audience = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsBroadcastController());
    final isSegment = _audience == 'segment';
    final isSelected = _audience == 'selected';

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Broadcast notifications'.tr,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
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
                  Text('Audience'.tr, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: AppSizes.sm),
                  DropdownButton<String>(
                    value: _audience,
                    dropdownColor: AppColors.card,
                    items: [
                      DropdownMenuItem(value: 'all', child: Text('All'.tr)),
                      DropdownMenuItem(value: 'segment', child: Text('Segment'.tr)),
                      DropdownMenuItem(value: 'customers', child: Text('Customers'.tr)),
                      DropdownMenuItem(value: 'artisans', child: Text('Artisans'.tr)),
                      DropdownMenuItem(value: 'admins', child: Text('Admins'.tr)),
                      DropdownMenuItem(value: 'selected', child: Text('Selected'.tr)),
                    ],
                    onChanged: (value) => setState(() => _audience = value ?? 'all'),
                  ),
                  if (isSegment) ...[
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _topicController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Segment topic'.tr,
                        hintText: 'seg_example'.tr,
                      ),
                    ),
                  ],
                  if (isSelected) ...[
                    const SizedBox(height: AppSizes.md),
                    TextFormField(
                      controller: _customerIdsController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Customer IDs'.tr,
                        hintText: 'id1,id2'.tr,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextFormField(
                      controller: _artisanIdsController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Artisan IDs'.tr,
                        hintText: 'id1,id2'.tr,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    TextFormField(
                      controller: _adminIdsController,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Admin IDs'.tr,
                        hintText: 'id1,id2'.tr,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(labelText: 'Title'.tr),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Title'.tr : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _bodyController,
                    style: const TextStyle(color: AppColors.text),
                    maxLines: 4,
                    decoration: InputDecoration(labelText: 'Message'.tr),
                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Message'.tr : null,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  Obx(
                    () => PrimaryButton(
                      expand: true,
                      label: controller.sending.value ? 'Loading'.tr : 'Send notification'.tr,
                      icon: Icons.campaign_outlined,
                      onPressed: controller.sending.value
                          ? null
                          : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) return;
                              if (isSegment && _topicController.text.trim().isEmpty) {
                                showError('Segment topic required'.tr);
                                return;
                              }
                              if (isSegment && !_topicController.text.trim().startsWith('seg_')) {
                                showError('Segment topic must start with seg_'.tr);
                                return;
                              }
                              if (isSelected && !_hasAnyIds()) {
                                showError('Please enter at least one ID'.tr);
                                return;
                              }
                              await controller.broadcast(
                                audience: _audience,
                                title: _titleController.text.trim(),
                                body: _bodyController.text.trim(),
                                topic: isSegment ? _topicController.text.trim() : null,
                                customerIds: _splitIds(_customerIdsController.text),
                                artisanIds: _splitIds(_artisanIdsController.text),
                                adminIds: _splitIds(_adminIdsController.text),
                              );
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

  List<String> _splitIds(String raw) {
    return raw
        .split(RegExp(r'[,\s]+'))
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
  }

  bool _hasAnyIds() {
    return _splitIds(_customerIdsController.text).isNotEmpty ||
        _splitIds(_artisanIdsController.text).isNotEmpty ||
        _splitIds(_adminIdsController.text).isNotEmpty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _topicController.dispose();
    _customerIdsController.dispose();
    _artisanIdsController.dispose();
    _adminIdsController.dispose();
    super.dispose();
  }
}
