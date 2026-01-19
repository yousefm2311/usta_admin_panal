import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/notifications_tokens_controller.dart';

class NotificationsTokensView extends StatefulWidget {
  const NotificationsTokensView({super.key});

  @override
  State<NotificationsTokensView> createState() => _NotificationsTokensViewState();
}

class _NotificationsTokensViewState extends State<NotificationsTokensView> {
  final _topicController = TextEditingController();
  final _deviceIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsTokensController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FCM tokens'.tr,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadTokens,
                icon: const Icon(Icons.refresh, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _tokensTable(controller),
          const SizedBox(height: AppSizes.md),
          Text(
            'Topic subscriptions'.tr,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _topicController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Topic'.tr,
                    hintText: 'seg_marketing'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                TextField(
                  controller: _deviceIdController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Device ID (optional)'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Obx(
                  () => Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.actioning.value
                              ? null
                              : () async {
                                  final topic = _topicController.text.trim();
                                  if (topic.isEmpty) {
                                    showError('Topic is required'.tr);
                                    return;
                                  }
                                  await controller.subscribe(
                                    topic: topic,
                                    deviceId: _deviceIdController.text.trim().isEmpty
                                        ? null
                                        : _deviceIdController.text.trim(),
                                  );
                                },
                          child: Text('Subscribe'.tr),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.text,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          onPressed: controller.actioning.value
                              ? null
                              : () async {
                                  final topic = _topicController.text.trim();
                                  if (topic.isEmpty) {
                                    showError('Topic is required'.tr);
                                    return;
                                  }
                                  await controller.unsubscribe(
                                    topic: topic,
                                    deviceId: _deviceIdController.text.trim().isEmpty
                                        ? null
                                        : _deviceIdController.text.trim(),
                                  );
                                },
                          child: Text('Unsubscribe'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tokensTable(NotificationsTokensController controller) {
    return Obx(() {
      if (controller.loading.value) {
        return const ListLoading(rows: 4, itemHeight: 46);
      }
      if (controller.error.value != null) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
        );
      }
      if (controller.tokens.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
        );
      }

      return TableWrapper(
        child: DataTable(
          columns: [
            DataColumn(label: Text('Token'.tr)),
            DataColumn(label: Text('Device'.tr)),
            DataColumn(label: Text('Platform'.tr)),
            DataColumn(label: Text('Created'.tr)),
          ],
          rows: controller.tokens
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _shorten(_field(item, ['token', 'fcmToken', 'value'])),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy'.tr,
                            icon: const Icon(Icons.copy, size: 16, color: AppColors.textMuted),
                            onPressed: () => _copyToken(_field(item, ['token', 'fcmToken', 'value'])),
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(_field(item, ['deviceId', 'device', 'device_id']))),
                    DataCell(Text(_field(item, ['platform', 'os']))),
                    DataCell(Text(_field(item, ['createdAt', 'created', 'date']))),
                  ],
                ),
              )
              .toList(),
          headingTextStyle: const TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
          dataTextStyle: const TextStyle(color: AppColors.text),
        ),
      );
    });
  }

  String _field(dynamic item, List<String> keys) {
    if (item is Map<String, dynamic>) {
      for (final key in keys) {
        final value = item[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return '';
  }

  String _shorten(String value) {
    if (value.length <= 18) return value;
    return '${value.substring(0, 10)}...${value.substring(value.length - 6)}';
  }

  Future<void> _copyToken(String value) async {
    if (value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: value));
    showSuccess('Copied'.tr);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }
}
