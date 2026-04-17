import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/formate_date.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/report_details_controller.dart';

class ReportDetailsView extends StatefulWidget {
  const ReportDetailsView({super.key});

  @override
  State<ReportDetailsView> createState() => _ReportDetailsViewState();
}

class _ReportDetailsViewState extends State<ReportDetailsView> {
  late final ReportDetailsController controller;
  final TextEditingController replyController = TextEditingController();
  String reportId = '';
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReportDetailsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    reportId = (args?['_id'] ?? args?['id'] ?? '').toString();
    if (reportId.isNotEmpty) {
      controller.load(reportId);
      loadedOnce = true;
    }
  }

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 8);
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
        final report = controller.report.value;
        if (report == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final thread =
            (report['messages'] ?? report['thread'] ?? report['replies'] ?? [])
                as List<dynamic>;
        final status = (report['status'] ?? '').toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AdminBreadcrumbs(
              items: [
                AdminBreadcrumbItem(label: 'Reports', route: '/reports'),
                AdminBreadcrumbItem(label: 'Report details'),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            AdminPageHeader(
              title: 'Report details',
              subtitle:
                  'Review the report summary, thread, and moderation actions in one place.',
              badges: [
                AdminInfoBadge(
                  icon: Icons.report_problem_outlined,
                  label: 'Reports / Report details',
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Report summary',
              subtitle: 'Status overview',
              icon: Icons.report_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _subject(report),
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    '${'Reporter'.tr}: ${_reporterName(report)}',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  Text(
                    '${'Status'.tr}: ${status.tr}',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  Text(
                    '${'Date'.tr}: ${formatDateString(report['createdAt'] ?? report['date'])}',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    (report['description'] ??
                            report['message'] ??
                            report['details'] ??
                            '')
                        .toString(),
                    style: TextStyle(color: AppColors.text),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Thread',
              subtitle: 'Recent activity',
              icon: Icons.chat_bubble_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thread.isEmpty)
                    Text(
                      'No data'.tr,
                      style: TextStyle(color: AppColors.textMuted),
                    )
                  else
                    ...thread.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (m['sender'] ?? m['senderType'] ?? '').toString(),
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              (m['message'] ?? m['text'] ?? '').toString(),
                              style: TextStyle(color: AppColors.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AdminSectionCard(
              title: 'Reply',
              subtitle: 'Moderation actions',
              icon: Icons.reply_all_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: replyController,
                    style: TextStyle(color: AppColors.text),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type notification message'.tr,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            controller.reply(reportId, replyController.text),
                        icon: const Icon(Icons.send),
                        label: Text('Send reply'.tr),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.text,
                        ),
                        onPressed: () => controller.close(reportId),
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('Close report'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
}
