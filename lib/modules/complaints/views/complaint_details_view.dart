import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/complaint_details_controller.dart';

class ComplaintDetailsView extends StatefulWidget {
  const ComplaintDetailsView({super.key});

  @override
  State<ComplaintDetailsView> createState() => _ComplaintDetailsViewState();
}

class _ComplaintDetailsViewState extends State<ComplaintDetailsView> {
  late final ComplaintDetailsController controller;
  final TextEditingController agentController = TextEditingController();
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
      controller.load(complaintId);
      loadedOnce = true;
    }
  }

  @override
  void dispose() {
    agentController.dispose();
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
              const ListLoading(rows: 1,itemHeight: 40),
              const CardLoading(lines: 8),
              const ListLoading(rows: 2, itemHeight: 40),
            ],
          );
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final data = controller.complaint.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
          );
        }
        final thread = (data['messages'] ?? data['thread'] ?? []) as List<dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        Text(
              'Complaint Details'.tr,
              style:  TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data['issue'] ?? data['title'] ?? '').toString(),
                    style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${"Complainant".tr} - ${(data['messages'][0]['senderType'] ?? '')}',
                    style:  TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thread'.tr, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  ...thread.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (m['senderType'] ?? '').toString(),
                              style:  TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (m['message'] ?? m['text'] ?? '').toString(),
                              style:  TextStyle(color: AppColors.text),
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
                  onPressed: () => controller.updateStatus(complaintId, 'assigned'),
                  child: Text('Assign to support'.tr),
                ),
                const SizedBox(width: AppSizes.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:  BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.text,
                  ),
                  onPressed: () => controller.updateStatus(complaintId, 'closed'),
                  child: Text('close'.tr),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Assign agent'.tr, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: agentController,
                          style:  TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'Agent ID'.tr,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => controller.assignAgent(complaintId, agentController.text),
                        child: Text('Assign'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text('Internal note'.tr, style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: noteController,
                          style:  TextStyle(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'Add note'.tr,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      ElevatedButton(
                        onPressed: () => controller.addNote(complaintId, noteController.text),
                        child: Text('Save'.tr),
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
              style:  TextStyle(color: AppColors.text),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) {
                  controller.addMessage(complaintId, v.trim());
                }
              },
            ),
          ],
        );
      }),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }
}


