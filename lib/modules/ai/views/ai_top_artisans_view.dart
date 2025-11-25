import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class AITopArtisansView extends StatelessWidget {
  const AITopArtisansView({super.key});

  @override
  Widget build(BuildContext context) {
    final artisans = [...MockData.artisans]..sort((a, b) => b.completed.compareTo(a.completed));

    return AdminLayout(
      title: 'AI Top Artisans',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.toNamed('/ai/reviews'),
          icon: const Icon(Icons.insights_outlined),
          label: Text('Reviews insights'.tr),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                ...artisans.asMap().entries.map(
                  (entry) {
                    final rank = entry.key + 1;
                    final artisan = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.12),
                            child: Text('$rank', style: const TextStyle(color: AppColors.text)),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(artisan.name, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                                Text(
                                  artisan.category,
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(artisan.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.text)),
                            ],
                          ),
                          const SizedBox(width: AppSizes.md),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${artisan.completed} completed',
                              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
