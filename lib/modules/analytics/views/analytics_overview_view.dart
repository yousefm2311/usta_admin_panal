import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsOverviewView extends StatelessWidget {
  const AnalyticsOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AnalyticsController());
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerGridPlaceholder(count: 2),
              SizedBox(height: AppSizes.lg),
              ShimmerCardPlaceholder(height: 260, lines: 4),
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

        final data = controller.daily;
        final maxRequests = data.isNotEmpty
            ? data.map((e) => (e['requests'] ?? 0) as num).reduce(max)
            : 0;
        final maxEarnings = data.isNotEmpty
            ? data.map((e) => (e['earnings'] ?? 0) as num).reduce(max)
            : 0;

        final chartWidgets = <Widget>[
          _chartCard(
            title: 'Requests per month'.tr,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            (data[idx]['month'] ?? '').toString(),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < data.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (data[i]['requests'] ?? 0).toDouble(),
                          color: AppColors.primary,
                          width: 14,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    ),
                ],
                maxY: (maxRequests.toDouble()) + 10,
              ),
            ),
          ),
          _chartCard(
            title: 'Earnings per month'.tr,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= data.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            (data[idx]['month'] ?? '').toString(),
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    spots: [
                      for (var i = 0; i < data.length; i++)
                        FlSpot(
                          i.toDouble(),
                          (data[i]['earnings'] ?? 0).toDouble(),
                        ),
                    ],
                    color: AppColors.success,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.success.withOpacity(0.12),
                    ),
                  ),
                ],
                maxY: (maxEarnings.toDouble()) + 100,
              ),
            ),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics'.tr,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: [
                _statCard(
                  'Requests this month'.tr,
                  '${maxRequests.toInt()}',
                  Icons.timeline,
                ),
                _statCard(
                  'Earnings this month'.tr,
                  'EG ${maxEarnings.toStringAsFixed(0)}',
                  Icons.trending_up,
                ),
                _statCard('Avg. rating'.tr, '4.8', Icons.star),
              ],
            ),
            const SizedBox(height: AppSizes.lg),
            if (isMobile)
              Column(
                children: [
                  chartWidgets.first,
                  const SizedBox(height: AppSizes.md),
                  chartWidgets.last,
                ],
              )
            else
              Row(
                children: [
                  Expanded(child: chartWidgets.first),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: chartWidgets.last),
                ],
              ),
          ],
        );
      }),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      constraints: const BoxConstraints(minWidth: 160, maxWidth: 220),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title, style: const TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(height: 260, child: child),
        ],
      ),
    );
  }
}
