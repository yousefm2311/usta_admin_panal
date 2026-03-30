import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/complaint_details_controller.dart';

class ComplaintDetailsView extends StatefulWidget {
  const ComplaintDetailsView({super.key});

  @override
  State<ComplaintDetailsView> createState() => _ComplaintDetailsViewState();
}

class _ComplaintDetailsViewState extends State<ComplaintDetailsView> {
  late final ComplaintDetailsController controller;
  final TextEditingController noteController = TextEditingController();
  String complaintId = '';
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ComplaintDetailsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    complaintId = (args?['_id'] ?? args?['id'] ?? '').toString();
    if (complaintId.isNotEmpty) {
      controller.load(complaintId).then((_) => controller.loadSupportAgents());
      loadedOnce = true;
    }
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return Column(
            children: [
              const ListLoading(rows: 1, itemHeight: 40),
              const CardLoading(lines: 8),
              const ListLoading(rows: 2, itemHeight: 40),
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

        final data = controller.complaint.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final thread = _extractThread(data);
        final complainant = _resolveComplainant(data, thread);
        final agents = controller.supportAgents;
        final selectedAgentId = controller.selectedAgentId.value;
        final hasSelectedAgent =
            selectedAgentId.isNotEmpty &&
            agents.any((a) => a['id'] == selectedAgentId);
        final busy = controller.anyActionLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint Details'.tr,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['issue'] ?? data['title'] ?? '').toString(),
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${"Complainant".tr} - $complainant',
                    style: TextStyle(color: AppColors.textMuted),
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
                    'Thread'.tr,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  if (thread.isEmpty)
                    Text(
                      'No data'.tr,
                      style: TextStyle(color: AppColors.textMuted),
                    )
                  else
                    ...thread.map<Widget>(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSizes.sm),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.overlay,
                            borderRadius: BorderRadius.circular(
                              AppSizes.inputRadius,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (m['senderType'] ?? '').toString(),
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (m['message'] ?? m['text'] ?? '').toString(),
                                style: TextStyle(color: AppColors.text),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                ElevatedButton(
                  onPressed: busy
                      ? null
                      : () => controller.updateStatus(complaintId, 'assigned'),
                  child: controller.assigningToSupportLoading.value
                      ? _buttonLoading()
                      : Text('Assign to support'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                  ),
                  onPressed: busy
                      ? null
                      : () => controller.updateStatus(complaintId, 'closed'),
                  child: controller.closingLoading.value
                      ? _buttonLoading()
                      : Text('Close'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign agent'.tr,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      final picker = DropdownButtonFormField<String>(
                        value: hasSelectedAgent ? selectedAgentId : null,
                        dropdownColor: AppColors.card,
                        isExpanded: true,
                        items: agents
                            .map(
                              (a) => DropdownMenuItem<String>(
                                value: a['id'],
                                child: Text(
                                  (a['name'] ?? '—').toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (controller.agentsLoading.value || busy)
                            ? null
                            : (v) => controller.selectAgent(v ?? ''),
                        decoration: InputDecoration(
                          hintText: 'Choose agent'.tr,
                        ),
                      );

                      final refreshAgentsButton = IconButton(
                        tooltip: 'Refresh'.tr,
                        onPressed: (controller.agentsLoading.value || busy)
                            ? null
                            : () => controller.loadSupportAgents(force: true),
                        icon: controller.agentsLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.refresh_rounded,
                                color: AppColors.textMuted,
                              ),
                      );

                      final assignAgentButton = ElevatedButton(
                        onPressed:
                            (!busy &&
                                hasSelectedAgent &&
                                !controller.agentsLoading.value)
                            ? () => controller.assignSelectedAgent(complaintId)
                            : null,
                        child: controller.assigningAgentLoading.value
                            ? _buttonLoading()
                            : Text('Assign'.tr),
                      );

                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            picker,
                            const SizedBox(height: AppSizes.sm),
                            Row(
                              children: [
                                refreshAgentsButton,
                                const SizedBox(width: AppSizes.sm),
                                assignAgentButton,
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: picker),
                          const SizedBox(width: AppSizes.sm),
                          refreshAgentsButton,
                          const SizedBox(width: AppSizes.sm),
                          assignAgentButton,
                        ],
                      );
                    },
                  ),
                  if (agents.isEmpty && !controller.agentsLoading.value)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSizes.xs),
                      child: Text(
                        'No agents found'.tr,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    'Internal note'.tr,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          style: TextStyle(color: AppColors.text),
                          decoration: InputDecoration(hintText: 'Add note'.tr),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: busy
                            ? null
                            : () => controller.addNote(
                                complaintId,
                                noteController.text,
                              ),
                        child: controller.savingNoteLoading.value
                            ? _buttonLoading()
                            : Text('Save'.tr),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type notification message'.tr,
                filled: true,
              ),
              style: TextStyle(color: AppColors.text),
              onSubmitted: (v) {
                if (!controller.sendingMessageLoading.value &&
                    v.trim().isNotEmpty) {
                  controller.addMessage(complaintId, v.trim());
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _buttonLoading() {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  List<Map<String, dynamic>> _extractThread(Map<String, dynamic> data) {
    final source = data['messages'] ?? data['thread'] ?? const <dynamic>[];
    if (source is! List) return <Map<String, dynamic>>[];
    return source
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String _resolveComplainant(
    Map<String, dynamic> data,
    List<Map<String, dynamic>> thread,
  ) {
    final customerName = _nameFrom(data['customer'] ?? data['customerId']);
    if (customerName.isNotEmpty) return customerName;

    final createdByType = (data['createdByType'] ?? '').toString().trim();
    if (createdByType.isNotEmpty) return createdByType.tr;

    if (thread.isNotEmpty) {
      final senderType = (thread.first['senderType'] ?? '').toString().trim();
      if (senderType.isNotEmpty) return senderType.tr;
    }

    return '—';
  }

  String _nameFrom(dynamic value) {
    if (value is Map<String, dynamic>) {
      final raw =
          value['name'] ??
          value['fullName'] ??
          value['displayName'] ??
          value['userName'] ??
          value['username'] ??
          value['email'] ??
          value['phone'];
      final text = (raw ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    } else if (value is String) {
      final text = value.trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}
