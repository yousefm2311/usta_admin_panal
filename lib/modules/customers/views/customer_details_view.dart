import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends StatefulWidget {
  const CustomerDetailsView({super.key});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final isMobile = Responsive.isMobile(context);
    final controller = Get.put(CustomerDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: 'Customer details'.tr,
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
        final data = controller.customer.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }
        final requests = (data['lastRequests'] ?? []) as List<dynamic>;
        final isBlocked = data['blocked'] == true;
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
                                  Text(isBlocked ? 'Blocked'.tr : 'Active'.tr,
                                      style: TextStyle(color: isBlocked ? AppColors.danger : AppColors.success)),
                                ],
                              ),
                              const Spacer(),
                              Switch(
                                value: !isBlocked,
                                onChanged: (val) => controller.blockToggle(id, block: !val),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Wrap(
                            spacing: AppSizes.md,
                            runSpacing: AppSizes.md,
                            children: [
                              _stat('Total requests label'.tr, (data['requests'] ?? data['totalRequests'] ?? '0').toString()),
                              _stat('Completed label'.tr, (data['completed'] ?? '').toString()),
                              _stat('Canceled'.tr, (data['canceled'] ?? '').toString()),
                              _stat('Lifetime spend'.tr, (data['lifetimeSpend'] ?? '').toString()),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            (data['location'] ?? data['preferredLocation'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.textMuted),
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
                          Text('Last requests'.tr, style: const TextStyle(color: AppColors.text)),
                          const SizedBox(height: AppSizes.sm),
                          ...requests.map(
                            (r) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.xs),
                              child: Row(
                                children: [
                                  Expanded(child: Text((r['service'] ?? '').toString(), style: const TextStyle(color: AppColors.text))),
                                  _statusChip((r['status'] ?? '').toString()),
                                ],
                              ),
                            ),
                          ),
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
                    Text('Last requests'.tr, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSizes.sm),
                    ...requests.map(
                      (r) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text((r['service'] ?? '').toString(), style: const TextStyle(color: AppColors.text)),
                        subtitle: Text(
                            '${r['customer'] ?? ''} • ${r['artisan'] ?? ''}', style: const TextStyle(color: AppColors.textMuted)),
                        trailing: _statusChip((r['status'] ?? '').toString()),
                      ),
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

  Widget _statusChip(String status) {
    final color = status.toLowerCase() == 'completed' ? AppColors.success : AppColors.primary;
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
