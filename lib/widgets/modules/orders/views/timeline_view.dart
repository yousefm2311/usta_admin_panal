import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/order_details_controller.dart';

class OrderTimelineView extends StatefulWidget {
  const OrderTimelineView({super.key});

  @override
  State<OrderTimelineView> createState() => _OrderTimelineViewState();
}

class _OrderTimelineViewState extends State<OrderTimelineView> {
  late final OrderDetailsController controller;

  String orderId = '';
  final RxString status = 'pending'.obs;
  final TextEditingController noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(OrderDetailsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments as Map<String, dynamic>?;
      orderId = (args?['_id'] ?? args?['id'] ?? '').toString();

      if (orderId.isNotEmpty) {
        controller.load(orderId);
      } else {
        controller.error.value = 'No ID'.tr;
      }
    });
  }

  @override
  void dispose() {
    noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const TimelineLoading();
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

        final steps = controller.timeline;
        if (steps.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminBreadcrumbs(
                items: [
                  AdminBreadcrumbItem(label: 'Orders', route: '/orders'),
                  AdminBreadcrumbItem(label: 'Timeline'),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              AdminPageHeader(
                title: 'Timeline',
                subtitle:
                    'Follow every status change and add new timeline steps without leaving the order workflow.',
                badges: [
                  AdminInfoBadge(
                    icon: Icons.route_outlined,
                    label: 'Orders / Timeline',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline'.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    ...steps.asMap().entries.map((e) {
                      final raw = e.value;
                      final step = raw is Map<String, dynamic>
                          ? raw
                          : <String, dynamic>{};
                      final idx = e.key;
                      final isLast = idx == steps.length - 1;
                      final stepStatus = (step['status'] ?? '').toString();
                      final note = (step['note'] ?? '').toString();
                      final createdAt = formatDateString(step['createdAt']);
                      final subtitle = note.trim().isNotEmpty
                          ? note
                          : createdAt;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 34,
                              child: Column(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(
                                        0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(
                                          0.35,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (!isLast)
                                    Container(
                                      width: 2,
                                      height: 44,
                                      margin: const EdgeInsets.only(top: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.border.withOpacity(
                                          0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppSizes.md),
                                decoration: BoxDecoration(
                                  color: AppColors.overlay,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.inputRadius,
                                  ),
                                  border: Border.all(
                                    color: AppColors.border.withOpacity(0.6),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      stepStatus.tr,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      subtitle.isEmpty ? '-' : subtitle,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: AppSizes.sm),
                    Divider(color: AppColors.border),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      'Add timeline step'.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    LayoutBuilder(
                      builder: (ctx, c) {
                        final narrow = c.maxWidth < 560;

                        final drop = Obx(
                          () => DropdownButtonFormField<String>(
                            value: status.value,
                            dropdownColor: AppColors.card,
                            decoration: InputDecoration(labelText: 'Status'.tr),
                            items:
                                const [
                                  'pending',
                                  'accepted',
                                  'assigned',
                                  'in_progress',
                                  'completed',
                                  'cancelled',
                                  'closed',
                                ].map((s) {
                                  return DropdownMenuItem(
                                    value: s,
                                    child: Text(s.tr),
                                  );
                                }).toList(),
                            onChanged: (v) => status.value = v ?? status.value,
                          ),
                        );

                        final noteField = TextField(
                          controller: noteCtrl,
                          style: TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            labelText: 'Note'.tr,
                            hintText: 'Optional'.tr,
                          ),
                        );

                        final addBtn = Obx(() {
                          final isBusy = controller.addingTimeline.value;
                          return ElevatedButton.icon(
                            onPressed: isBusy || orderId.isEmpty
                                ? null
                                : () async {
                                    await controller.addTimeline(
                                      orderId,
                                      status: status.value,
                                      note: noteCtrl.text.trim(),
                                    );
                                    noteCtrl.clear();
                                  },
                            icon: isBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: Text(isBusy ? 'Adding...'.tr : 'Add'.tr),
                          );
                        });

                        final refreshBtn = OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.border),
                            foregroundColor: AppColors.text,
                          ),
                          onPressed: () => controller.load(orderId),
                          icon: const Icon(Icons.refresh),
                          label: Text('Refresh'.tr),
                        );

                        if (narrow) {
                          return Column(
                            children: [
                              drop,
                              const SizedBox(height: AppSizes.sm),
                              noteField,
                              const SizedBox(height: AppSizes.sm),
                              Row(
                                children: [
                                  Expanded(child: addBtn),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(child: refreshBtn),
                                ],
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            SizedBox(width: 220, child: drop),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(child: noteField),
                            const SizedBox(width: AppSizes.sm),
                            addBtn,
                            const SizedBox(width: AppSizes.sm),
                            refreshBtn,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
