import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/formate_date.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
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
      child: Obx(() {
        final totalReports = controller.reports.length;
        final openReports = controller.reports.where((raw) {
          final report = raw is Map<String, dynamic>
              ? raw
              : <String, dynamic>{};
          return _normalizeStatusKey(report['status']) == 'open';
        }).length;
        final inReviewReports = controller.reports.where((raw) {
          final report = raw is Map<String, dynamic>
              ? raw
              : <String, dynamic>{};
          return _normalizeStatusKey(report['status']) == 'in_review';
        }).length;
        final Widget body;

        if (controller.loading.value) {
          body = const CardLoading(lines: 8);
        } else if (controller.error.value != null) {
          body = Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        } else if (controller.reports.isEmpty) {
          body = Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        } else {
          body = TableWrapper(
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
                        child: Text(reporter, overflow: TextOverflow.ellipsis),
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
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              title: 'Reports',
              subtitle:
                  'Review incoming reports, track moderation status, and jump into report threads fast.',
              actions: [
                IconButton(
                  onPressed: controller.loadReports,
                  icon: Icon(Icons.refresh, color: AppColors.textMuted),
                  tooltip: 'Refresh'.tr,
                ),
              ],
              badges: [
                AdminInfoBadge(
                  icon: Icons.report_outlined,
                  label: 'Reports queue',
                ),
                AdminInfoBadge(
                  icon: Icons.support_agent_outlined,
                  label: 'Need review',
                  color: Colors.amber.shade700,
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
                        label: 'Reports',
                        value: totalReports.toString(),
                        subtitle: 'Reports queue',
                        icon: Icons.inbox_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Open',
                        value: openReports.toString(),
                        subtitle: 'New moderation tasks',
                        icon: Icons.mark_email_unread_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'In review',
                        value: inReviewReports.toString(),
                        subtitle: 'Need review',
                        icon: Icons.manage_search_outlined,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
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
            const SizedBox(height: AppSizes.md),
            body,
          ],
        );
      }),
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
