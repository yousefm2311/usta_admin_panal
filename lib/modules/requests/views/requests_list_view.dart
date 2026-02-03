import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/requests_controller.dart';

class RequestsListView extends StatefulWidget {
  const RequestsListView({super.key});

  @override
  State<RequestsListView> createState() => _RequestsListViewState();
}

class _RequestsListViewState extends State<RequestsListView> {
  late final RequestsController controller;

  final statuses = const [
    'All',
    'new',
    'pending',
    'accepted',
    'assigned',
    'in_progress',
    'completed',
    'cancelled',
    'closed',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.put(RequestsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // غيّر الاسم لو عندك دالة مختلفة
      controller.loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Requests'.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadRequests,
                icon: Icon(Icons.refresh, color: AppColors.textMuted),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(color: AppColors.border),
                ),
                onPressed: () =>
                    _openMaintenanceDialog(context, isExpire: true),
                icon: const Icon(Icons.timelapse, size: 18),
                label: Text('Expire stale'.tr),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(color: AppColors.border),
                ),
                onPressed: () =>
                    _openMaintenanceDialog(context, isExpire: false),
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: Text('Auto confirm'.tr),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.sm),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Wrap(
                spacing: AppSizes.sm,
                children: statuses.map((status) {
                  final selected = controller.filter.value == status;
                  return ChoiceChip(
                    label: Text(_statusLabel(status).tr),
                    selected: selected,
                    onSelected: (_) => controller.changeFilter(status),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.card,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppColors.textMuted,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Table
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 8);
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
            if (controller.requests.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'No data'.tr,
                  style: TextStyle(color: AppColors.textMuted),
                ),
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
                rows: controller.requests.map((raw) {
                  final r = raw is Map<String, dynamic>
                      ? raw
                      : <String, dynamic>{};
                  final statusKey = _normalizeStatusKey(r['status']);
                  return DataRow(
                    cells: [
                      DataCell(Text(_resolveServiceName(r))),
                      DataCell(
                        Text(
                          _resolveName(
                            r['customer'] ??
                                r['customerId'] ??
                                r['client'] ??
                                r['user'],
                            fallback: r['customerName'] ??
                                r['clientName'] ??
                                r['userName'] ??
                                r['customerEmail'] ??
                                r['customerPhone'],
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          _resolveName(
                            r['artisan'] ??
                                r['artisanId'] ??
                                r['worker'] ??
                                r['technician'],
                            fallback: r['artisanName'] ??
                                r['workerName'] ??
                                r['technicianName'] ??
                                r['artisanPhone'],
                          ),
                        ),
                      ),
                      DataCell(_statusChip(statusKey)),
                      DataCell(Text(_formatDate(r['date'] ?? r['createdAt']))),
                      DataCell(
                        Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  Get.toNamed('/request/details', arguments: r),
                              child: Text('View details'.tr),
                            ),
                            const SizedBox(width: AppSizes.xs),
                            IconButton(
                              tooltip: 'Delete'.tr,
                              onPressed: () => _confirmDelete(context, r),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
                headingTextStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle: TextStyle(color: AppColors.text),
                headingRowColor: MaterialStateProperty.all(AppColors.overlay),
                dividerThickness: 0.2,
              ),
            );
          }),
        ],
      ),
    );
  }

  // -------- helpers --------

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  String _resolveName(dynamic value, {dynamic fallback}) {
    final direct = _stringFrom(value);
    if (direct.isNotEmpty) return direct;
    return _stringFrom(fallback);
  }

  String _resolveServiceName(Map<String, dynamic> request) {
    final direct = _stringFrom(
      request['serviceType'] ??
          request['serviceName'] ??
          request['service'] ??
          request['serviceTitle'],
      keys: const [
        'name',
        'title',
        'serviceName',
        'serviceType',
        'type',
        'label',
      ],
    );
    if (direct.isNotEmpty) return direct;

    final fromServiceId = _stringFrom(
      request['serviceId'] ?? request['serviceRef'],
      keys: const ['name', 'title', 'serviceName', 'type', 'label'],
    );
    if (fromServiceId.isNotEmpty) return fromServiceId;

    final fromCategory = _stringFrom(
      request['category'] ?? request['categoryId'],
      keys: const ['name', 'title', 'label'],
    );
    if (fromCategory.isNotEmpty) return fromCategory;

    return '-';
  }

  String _stringFrom(
    dynamic value, {
    List<String> keys = const [
      'name',
      'fullName',
      'displayName',
      'username',
      'email',
      'phone',
      'title',
      'label',
      'type',
    ],
  }) {
    if (value == null) return '';
    if (value is String || value is num) return value.toString();
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final raw = value[key];
        if (raw == null) continue;
        final text = raw.toString();
        if (text.trim().isNotEmpty) return text;
      }
    }
    return '';
  }

  String _normalizeStatusKey(dynamic raw) {
    final s = (raw ?? '').toString().trim().toLowerCase();
    final normalized = s.replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'inprogress':
      case 'in_progress':
        return 'in_progress';
      case 'cancelled':
      case 'canceled':
        return 'cancelled';
      default:
        return normalized.isEmpty ? 'new' : normalized;
    }
  }

  String _statusLabel(String key) {
    switch (key) {
      case 'all':
      case 'All':
        return 'All';
      case 'new':
        return 'New';
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'closed':
        return 'Closed';
      default:
        return key;
    }
  }

  Widget _statusChip(String key) {
    final color = _statusColor(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _statusLabel(key).tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'new':
        return AppColors.warning;
      case 'accepted':
      case 'assigned':
        return Colors.lightBlueAccent;
      case 'in_progress':
        return Colors.amber;
      case 'cancelled':
      case 'closed':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> request) {
    final id = (request['_id'] ?? request['id'] ?? '').toString();
    if (id.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete'.tr, style: TextStyle(color: AppColors.text)),
        content: Text(
          'Delete this request?'.tr,
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteRequest(id);
            },
            child: Text(
              'Delete'.tr,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _openMaintenanceDialog(BuildContext context, {required bool isExpire}) {
    final limitController = TextEditingController();
    final beforeController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(
          isExpire ? 'Expire stale requests'.tr : 'Auto confirm requests'.tr,
          style: TextStyle(color: AppColors.text),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Limit'.tr,
                hintText: 'Optional'.tr,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: beforeController,
              style: TextStyle(color: AppColors.text),
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
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final limit = int.tryParse(limitController.text.trim());
              final before = beforeController.text.trim().isEmpty
                  ? null
                  : beforeController.text.trim();

              if (isExpire) {
                await controller.expireStale(limit: limit, before: before);
              } else {
                await controller.autoConfirm(limit: limit, before: before);
              }
            },
            child: Text('Run'.tr, style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
