import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/request_details_controller.dart';
import '../../../core/utils/notify.dart';
import '../../../widgets/shimmer_widgets.dart';

class RequestDetailsView extends StatelessWidget {
  const RequestDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final controller = Get.put(RequestDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: 'Request details',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 6);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final req = controller.request.value;
        if (req == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }

        final price = double.tryParse((req['price'] ?? req['amount'] ?? 0).toString()) ?? 0;
        final images = (req['images'] ?? []) as List<dynamic>;
        final msgController = TextEditingController();
        final timelineStatus = 'pending'.obs;
        final timelineNote = TextEditingController();
        final actionNote = TextEditingController();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _card(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle('Service'.tr),
                        const SizedBox(height: 4),
                        Text((req['serviceType'] ?? req['service'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.text, fontSize: 16)),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Customer: ${(req['customer'] ?? req['customerName'] ?? '').toString()}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        Text(
                          'Artisan: ${(req['artisan'] ?? req['artisanName'] ?? '').toString()}',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  _statusChip((req['status'] ?? '').toString()),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Status timeline'.tr),
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: AppSizes.md,
                    runSpacing: AppSizes.sm,
                    children: controller.timeline
                        .map((step) => _timelineStep(
                              (step['status'] ?? '').toString(),
                              true,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Obx(
                        () => DropdownButton<String>(
                          value: timelineStatus.value,
                          dropdownColor: AppColors.card,
                          items: ['pending', 'accepted', 'in_progress', 'assigned', 'in_progress', 'completed', 'canceled', 'closed']
                              .toSet()
                              .map((s) => DropdownMenuItem(value: s, child: Text(s.tr)))
                              .toList(),
                          onChanged: (v) => timelineStatus.value = v ?? timelineStatus.value,
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
                        onPressed: () => controller.addTimeline(id, status: timelineStatus.value, note: timelineNote.text),
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
                  _sectionTitle('Images'.tr),
                  const SizedBox(height: AppSizes.sm),
                  if (images.isEmpty)
                    Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted))
                  else
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: images
                          .map(
                            (img) => Container(
                              width: 140,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppColors.overlay,
                                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                                border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                              ),
                              child: Center(
                                child: Text(img.toString(), style: const TextStyle(color: AppColors.textMuted)),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Chat (view only)'.tr),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                    child: controller.messages.isNotEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            children: controller.messages
                                .map<Widget>(
                                  (m) => Padding(
                                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text((m['sender'] ?? '').toString(),
                                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                        Text((m['message'] ?? '').toString(),
                                            style: const TextStyle(color: AppColors.text)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          )
                        : const Center(
                            child: Text('Conversation history placeholder', style: TextStyle(color: AppColors.textMuted)),
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
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Pricing'.tr),
                  const SizedBox(height: AppSizes.sm),
                  _priceRow('Base price'.tr, 'EG ${price.toStringAsFixed(0)}'),
                  _priceRow('VAT 5%'.tr, 'EG ${(price * 0.05).toStringAsFixed(2)}'),
                  const Divider(color: AppColors.border),
                  _priceRow(
                    'Total'.tr,
                    'EG ${(price * 1.05).toStringAsFixed(2)}',
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => controller.close(id, status: 'closed', note: actionNote.text.trim().isEmpty ? null : actionNote.text.trim()),
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text('Close order'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                  ),
                  onPressed: () => controller.cancel(
                    id,
                    reason: 'Canceled by admin',
                    note: actionNote.text.trim().isEmpty ? null : actionNote.text.trim(),
                  ),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text('Cancel'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: actionNote,
              style: const TextStyle(color: AppColors.text),
              decoration: InputDecoration(hintText: 'Note'.tr),
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

  Widget _timelineStep(String label, bool done) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: done ? AppColors.primary : AppColors.border,
          child: Icon(done ? Icons.check : Icons.radio_button_unchecked, size: 14, color: Colors.white),
        ),
        const SizedBox(width: AppSizes.sm),
        Text(label, style: TextStyle(color: done ? AppColors.text : AppColors.textMuted)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _statusChip(String status) {
    Color color;
    final normalized = status.replaceAll('_', ' ').toLowerCase();
    switch (normalized) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
        color = Colors.amber;
        break;
      case 'canceled':
      case 'cancelled':
        color = Colors.redAccent;
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
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}


