import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/order_details_controller.dart';

class OrderDetailsView extends StatelessWidget {
  const OrderDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(OrderDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return Column(
            children: [
              const CardLoading(lines: 6),
              const CardLoading(lines: 10),
              const CardLoading(lines: 6),
              const ListLoading(rows: 2,),
              const CardLoading(lines: 8,),
            ],
          );
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
        final order = controller.order.value;
        if (order == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        final price =
            double.tryParse(
              (order['amount'] ?? order['price'] ?? 0).toString(),
            ) ??
            0;
        final messages = controller.messages;
        final timelineStatus = 'in_progress'.obs;
        final timelineNote = TextEditingController();
        final actionNote = TextEditingController();
        final msgController = TextEditingController();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Details'.tr,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            _card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم الخدمة
                        Text(
                          (order['serviceType'] ?? order['service'] ?? '')
                              .toString(),
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   '${order['customer']?['name'] ?? 'Unknown'}',
                            //   style: const TextStyle(
                            //     color: AppColors.textMuted,
                            //     fontSize: 13,
                            //     height: 1.3,
                            //   ),
                            //   overflow: TextOverflow.ellipsis,
                            // ),

                            const SizedBox(height: 4),

                            // الحرفي
                            Text(
                              '${order['artisan']?['name'] ?? 'No artisan'} (${order['artisan']?['phone'] ?? ''})',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                height: 1.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '${"created".tr}: ${formatDateString(order['createdAt'])}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _statusChip((order['status'] ?? '').toString()),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status timeline'.tr,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.xs,
                    children: controller.timeline
                        .map(
                          (step) =>
                              _statusChip((step['status'] ?? '').toString()),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Obx(
                        () => DropdownButton<String>(
                          value: timelineStatus.value,
                          dropdownColor: AppColors.card,
                          items:  [
                            DropdownMenuItem(
                              value: 'pending',
                              child: Text('pending'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'accepted',
                              child: Text('accepted'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'assigned',
                              child: Text('assigned'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'in_progress',
                              child: Text('in_progress'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('completed'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'canceled',
                              child: Text('cancelled'.tr),
                            ),
                            DropdownMenuItem(
                              value: 'closed',
                              child: Text('closed'.tr),
                            ),
                          ],
                          onChanged: (v) =>
                              timelineStatus.value = v ?? timelineStatus.value,
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: TextField(
                          controller: timelineNote,
                          style: const TextStyle(color: AppColors.text),
                          decoration: InputDecoration(hintText: 'Note'.tr),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => controller.addTimeline(
                          id,
                          status: timelineStatus.value,
                          note: timelineNote.text,
                        ),
                        child: Text('Add'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment info'.tr,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _priceRow(
                    'Service total'.tr,
                    'EG ${price.toStringAsFixed(0)}',
                  ),
                  _priceRow(
                    'Platform fee'.tr,
                    'EG ${(price * 0.1).toStringAsFixed(2)}',
                  ),
                  const Divider(color: AppColors.border),
                  _priceRow(
                    'Total'.tr,
                    'EG ${(price * 1.1).toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.cancel(
                    id,
                    note: actionNote.text.trim().isEmpty
                        ? null
                        : actionNote.text.trim(),
                    reason: 'Canceled by admin',
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text('Cancel'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                  ),
                  onPressed: () => controller.close(
                    id,
                    note: actionNote.text.trim().isEmpty
                        ? null
                        : actionNote.text.trim(),
                  ),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Close order'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: actionNote,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(hintText: 'Note'.tr),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat (view only)'.tr,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                    child: messages.isNotEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            children: messages
                                .map<Widget>(
                                  (m) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSizes.sm,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          (m['sender'] ?? '').toString(),
                                          style: const TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          (m['message'] ?? '').toString(),
                                          style: const TextStyle(
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : const Center(
                            child: Text(
                              'Conversation history placeholder',
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  TextField(
                    controller: msgController,
                    style: const TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Type notification message'.tr,
                    ),
                    onSubmitted: (v) {
                      if (id.isEmpty) {
                        showError('No ID');
                        return;
                      }
                      controller.sendMessage(id, v);
                      msgController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: child,
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'assigned':
        color = Colors.lightBlueAccent;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
      case 'in_progress':
        color = Colors.amber;
        break;
      case 'canceled':
      case 'cancelled':
        color = AppColors.danger;
        break;
      case 'closed':
        color = AppColors.textMuted;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      margin: EdgeInsets.all(5),
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
