import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/requests_controller.dart';

class RequestsListView extends StatelessWidget {
  const RequestsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestsController());
    final statuses = ['All', 'New', 'Pending', 'Accepted', 'Assigned', 'In progress', 'Completed', 'Cancelled'];

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Requests'.tr,
                style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side:  BorderSide(color: AppColors.border),
                ),
                onPressed: () => _openMaintenanceDialog(context, controller, isExpire: true),
                icon: const Icon(Icons.timelapse, size: 18),
                label: Text('Expire stale'.tr),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side:  BorderSide(color: AppColors.border),
                ),
                onPressed: () => _openMaintenanceDialog(context, controller, isExpire: false),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('Auto confirm'.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Wrap(
                spacing: AppSizes.sm,
                children: statuses
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status.tr),
                        selected: controller.filter.value == status,
                        onSelected: (_) => controller.changeFilter(status),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: controller.filter.value == status ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 8);
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            if (controller.requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
              );
            }
            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Service'.tr)),
                  DataColumn(label: Text('Customers'.tr)),
                  DataColumn(label: Text('Artisan'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.requests
                    .map(
                      (r) => DataRow(
                        cells: [
                          DataCell(Text((r['service'] ?? r['serviceName'] ?? '').toString())),
                          DataCell(Text((r['customer'] ?? r['customerName'] ?? '').toString())),
                          DataCell(Text((r['artisan'] ?? r['artisanName'] ?? '').toString())),
                          DataCell(_statusChip((r['status'] ?? '').toString())),
                          DataCell(Text(_formatDate(r['date'] ?? r['createdAt']))),
                          DataCell(
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => Get.toNamed('/request/details', arguments: r),
                                  child: Text('View details'.tr),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                IconButton(
                                  tooltip: 'Delete'.tr,
                                  onPressed: () => _confirmDelete(context, controller, r),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                headingTextStyle:  TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle:  TextStyle(color: AppColors.text),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) {
      return '${value.day}/${value.month}/${value.year}';
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
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
      case 'in-progress':
        color = Colors.amber;
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

  void _confirmDelete(BuildContext context, RequestsController controller, Map<String, dynamic> request) {
    final id = (request['_id'] ?? request['id'] ?? '').toString();
    if (id.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete'.tr, style:  TextStyle(color: AppColors.text)),
        content: Text('Delete this request?'.tr, style:  TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr, style:  TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteRequest(id);
            },
            child: Text('Delete'.tr, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _openMaintenanceDialog(BuildContext context, RequestsController controller, {required bool isExpire}) {
    final limitController = TextEditingController();
    final beforeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          isExpire ? 'Expire stale requests'.tr : 'Auto confirm requests'.tr,
          style:  TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              style:  TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Limit'.tr,
                hintText: 'Optional'.tr,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: beforeController,
              style:  TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Before (ISO date)'.tr,
                hintText: '2024-01-01T00:00:00Z',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr, style:  TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final limit = int.tryParse(limitController.text.trim());
              final before = beforeController.text.trim().isEmpty ? null : beforeController.text.trim();
              if (isExpire) {
                await controller.expireStale(limit: limit, before: before);
              } else {
                await controller.autoConfirm(limit: limit, before: before);
              }
            },
            child: Text('Run'.tr, style:  TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}


