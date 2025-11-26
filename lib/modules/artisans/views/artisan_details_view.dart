import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/artisan_details_controller.dart';

class ArtisanDetailsView extends StatelessWidget {
  const ArtisanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final isMobile = Responsive.isMobile(context);
    final controller = Get.put(ArtisanDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: 'Artisan details',
      child: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        final data = controller.artisan.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        final docs = (data['documents'] ?? []) as List<dynamic>;
        final stats = (data['stats'] ?? {}) as Map<String, dynamic>;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(0.16),
                                child: const Icon(Icons.person, color: AppColors.primary),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((data['name'] ?? '').toString(),
                                      style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                                  Text((data['profession'] ?? data['category'] ?? '').toString(),
                                      style: const TextStyle(color: AppColors.textMuted)),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                (data['status'] ?? '').toString().tr,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Wrap(
                            spacing: AppSizes.md,
                            runSpacing: AppSizes.md,
                            children: [
                              _stat('Completed requests label'.tr, (stats['completed'] ?? '').toString()),
                              _stat('Active jobs'.tr, (stats['active'] ?? '').toString()),
                              _stat('Average ticket'.tr, (stats['avgTicket'] ?? '').toString()),
                              _stat('Member since'.tr, (data['createdAt'] ?? '').toString()),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => controller.approve(id),
                                child: Text('Approve'.tr),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.border),
                                  foregroundColor: AppColors.text,
                                ),
                                onPressed: () => controller.reject(id),
                                child: Text('Reject'.tr),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isMobile) const SizedBox(width: AppSizes.md),
                  if (!isMobile)
                    Container(
                      width: 240,
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Documents'.tr, style: const TextStyle(color: AppColors.text)),
                          const SizedBox(height: AppSizes.sm),
                          ...docs.map((d) => Padding(
                                padding: const EdgeInsets.only(bottom: AppSizes.xs),
                                child: Text(d.toString(), style: const TextStyle(color: AppColors.textMuted)),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ratings'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.sm),
                    Text((stats['rating'] ?? '').toString(), style: const TextStyle(color: AppColors.text)),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
