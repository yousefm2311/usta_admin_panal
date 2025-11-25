import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../data/providers/mock_data.dart';

class AIReviewsInsightsView extends StatelessWidget {
  const AIReviewsInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    final sentiment = MockData.sentiment;
    final total = sentiment.values.reduce((a, b) => a + b);

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
            child: Row(
              children: [
                SizedBox(
                  height: 220,
                  width: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 4,
                      centerSpaceRadius: 36,
                      sections: sentiment.entries.map((entry) {
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
                      ...sentiment.entries.map(
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
                                '${(entry.value / total * 100).toStringAsFixed(1)}%',
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
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text(
            'Word cloud'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.sm),
          Container(
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
              children: const [
                _Word('reliable', 18),
                _Word('on-time', 16),
                _Word('friendly', 14),
                _Word('clean', 20),
                _Word('professional', 16),
                _Word('responsive', 18),
                _Word('expensive', 14),
              ],
            ),
          ),
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
