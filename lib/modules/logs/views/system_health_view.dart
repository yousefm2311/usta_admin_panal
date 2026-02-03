import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/system_health_controller.dart';

class SystemHealthView extends StatelessWidget {
  const SystemHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SystemHealthController());

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const _SystemHealthShimmer();
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
        final data = controller.health.value ?? {};
        final items = [
          SystemHealthItem(
            title: 'API status'.tr,
            value: (data['apiStatus'] ?? '').toString(),
            color: AppColors.success,
            icon: Icons.cloud_sync,
          ),
          SystemHealthItem(
            title: 'Storage'.tr,
            value: (data['storage'] ?? '').toString(),
            color: Colors.amber,
            icon: Icons.storage_rounded,
          ),
          SystemHealthItem(
            title: 'Performance'.tr,
            value: (data['performance'] ?? '').toString(),
            color: AppColors.success,
            icon: Icons.speed_rounded,
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSizes.md),
            Text(
              'System Health'.tr,
              style:  TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: items.map((item) => _HealthCard(item)).toList(),
            ),
          ],
        );
      }),
    );
  }
}
class SystemHealthItem {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  SystemHealthItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
}
class _HealthCard extends StatelessWidget {
  final SystemHealthItem item;
  const _HealthCard(this.item);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style:  TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }
}
class _SystemHealthShimmer extends StatelessWidget {
  const _SystemHealthShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.md,
      runSpacing: AppSizes.md,
      children: List.generate(
        3,
        (i) => SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerBox(height: 20, width: 120),
              SizedBox(height: 10),
              ShimmerBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
