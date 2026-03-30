import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/formate_date.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/reports_controller.dart';

class ReportsListView extends StatefulWidget {
  const ReportsListView({super.key});

  @override
  State<ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends State<ReportsListView> {
  late final ReportsController controller;

  final statuses = const ['All', 'Open', 'In review', 'Closed'];

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReportsController());

    // load once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadReports();
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
                'Reports'.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: controller.loadReports,
                icon: Icon(Icons.refresh, color: AppColors.textMuted),
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
                children: statuses
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status.tr),
                        selected: controller.filter.value == status,
                        onSelected: (_) => controller.changeFilter(status),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.card,
                        labelStyle: TextStyle(
                          color: controller.filter.value == status
                              ? Colors.white
                              : AppColors.textMuted,
                        ),
                      ),
                    )
                    .toList(),
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
            if (controller.reports.isEmpty) {
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
                  DataColumn(label: Text('Reporter'.tr)),
                  DataColumn(label: Text('Subject'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.reports.map((r) {
                  final reporter = _reporterName(r);
                  final subject = _subject(r);
                  final statusKey = _normalizeStatusKey(r['status']);
                  final date = formatDateString(r['createdAt'] ?? r['date']);

                  return DataRow(
                    cells: [
                      DataCell(
                        Tooltip(
                          message: reporter,
                          child: Text(
                            reporter,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        Tooltip(
                          message: subject,
                          child: SizedBox(
                            width: 260,
                            child: Text(
                              subject,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      DataCell(_statusChip(statusKey)),
                      DataCell(Text(date)),
                      DataCell(
                        TextButton(
                          onPressed: () =>
                              Get.toNamed('/report/details', arguments: r),
                          child: Text('View details'.tr),
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

  String _reporterName(Map<String, dynamic> r) {
    final reporter = r['reporter'] ?? r['customer'] ?? r['user'] ?? r['owner'];
    if (reporter is Map<String, dynamic>) {
      return (reporter['name'] ??
              reporter['fullName'] ??
              reporter['email'] ??
              '')
          .toString();
    }
    return (r['reporterName'] ?? r['customerName'] ?? '').toString();
  }

  String _subject(Map<String, dynamic> r) {
    return (r['subject'] ?? r['title'] ?? r['issue'] ?? r['reason'] ?? '')
        .toString();
  }

  String _normalizeStatusKey(dynamic raw) {
    final s = (raw ?? '').toString().trim().toLowerCase();
    final normalized = s.replaceAll('-', '_').replaceAll(' ', '_');
    switch (normalized) {
      case 'inreview':
      case 'in_review':
        return 'in_review';
      case 'open':
        return 'open';
      case 'closed':
        return 'closed';
      default:
        return normalized.isEmpty ? 'open' : normalized;
    }
  }

  Widget _statusChip(String key) {
    final color = _statusColor(key);
    final label = _statusLabel(key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _statusLabel(String key) {
    switch (key) {
      case 'open':
        return 'Open';
      case 'in_review':
        return 'In review';
      case 'closed':
        return 'Closed';
      default:
        return key;
    }
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'open':
        return AppColors.warning;
      case 'in_review':
        return Colors.amber;
      case 'closed':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }
}
