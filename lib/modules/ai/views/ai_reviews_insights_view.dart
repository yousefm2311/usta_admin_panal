import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/ai_controller.dart';

class AIReviewsInsightsView extends StatelessWidget {
  const AIReviewsInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIController());

    return AdminLayout(
      title: 'AI Reviews Insights',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.toNamed('/ai/top-artisans'),
          icon: const Icon(Icons.leaderboard),
          label: Text('Top artisans CTA'.tr),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI sentiment overview'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Obx(() {
              if (controller.loadingSentiment.value) {
                return const Center(child: Padding(padding: EdgeInsets.all(AppSizes.lg), child: CircularProgressIndicator(color: AppColors.primary)));
              }
              if (controller.sentiment.isEmpty) {
                return Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted));
              }
              final total = controller.sentiment.values.fold<double>(0, (a, b) => a + b);
              return Row(
                children: [
                  SizedBox(
                    height: 220,
                    width: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 36,
                        sections: controller.sentiment.entries.map((entry) {
                          final color = _sentimentColor(entry.key);
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${entry.key}\n${entry.value.toStringAsFixed(0)}%',
                            radius: 70,
                            titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sentiment breakdown'.tr, style: const TextStyle(color: AppColors.text)),
                        const SizedBox(height: AppSizes.sm),
                        ...controller.sentiment.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _sentimentColor(entry.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(color: AppColors.text),
                                  ),
                                ),
                                Text(
                                  total == 0 ? '0%' : '${(entry.value / total * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Word cloud'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.sm),
          Obx(() {
            if (controller.loadingWordCloud.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.md),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (controller.wordCloud.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
                ),
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
              ),
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: controller.wordCloud
                    .map((w) => _Word(w, 14 + (w.length % 6).toDouble()))
                    .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _sentimentColor(String label) {
    switch (label) {
      case 'Positive':
        return AppColors.success;
      case 'Neutral':
        return Colors.blueGrey;
      default:
        return AppColors.danger;
    }
  }
}

class _Word extends StatelessWidget {
  final String text;
  final double size;

  const _Word(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.text,
        fontWeight: FontWeight.bold,
        fontSize: size,
      ),
    );
  }
}
