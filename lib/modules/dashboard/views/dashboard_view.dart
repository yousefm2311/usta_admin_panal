import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final analytics = MockData.analytics;
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: 'Dashboard',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.md,
            children: _buildStatCards(context),
          ),
          const SizedBox(height: AppSizes.lg),
          _sectionTitle('Monthly performance'.tr),
          const SizedBox(height: AppSizes.sm),
          _card(
            child: SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= analytics.length) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              analytics[index].month,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < analytics.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: analytics[i].requests,
                            color: AppColors.primary,
                            width: 18,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                  ],
                  maxY: analytics.map((e) => e.requests).reduce(max) + 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          if (isMobile)
            Column(
              children: [
                _latestRequestsSection(),
                const SizedBox(height: AppSizes.md),
                _topArtisansSection(),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _latestRequestsSection()),
                const SizedBox(width: AppSizes.md),
                Expanded(child: _topArtisansSection()),
              ],
            ),
        ],
      ),
    );
  }

  List<Widget> _buildStatCards(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final cardWidth = isDesktop
        ? (MediaQuery.of(context).size.width - 400) / 4
        : isTablet
            ? (MediaQuery.of(context).size.width - 220) / 2
            : MediaQuery.of(context).size.width - 48;

    final List<(String title, String value, Color color, IconData icon)> stats = [
      ('Total Requests'.tr, '384', AppColors.primary, Icons.timeline),
      ('Completed Requests'.tr, '227', AppColors.success, Icons.check_circle_outline),
      ('Active Requests'.tr, '14', Colors.amber, Icons.run_circle_outlined),
      ('Total Earnings'.tr, 'EG 12,480', Colors.tealAccent, Icons.payments_outlined),
    ];

    return stats
        .map(
          (s) => SizedBox(
            width: cardWidth < 220 ? double.infinity : cardWidth,
            child: _card(
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: s.$3.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(s.$4, color: s.$3),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$2,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        s.$1,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _latestRequestsSection() {
    final requests = MockData.requests;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Latest requests'.tr),
          const SizedBox(height: AppSizes.sm),
          ...requests.map(
            (req) => Container(
              margin: const EdgeInsets.only(bottom: AppSizes.sm),
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.overlay,
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.build, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          req.service,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${req.customer} • ${req.artisan}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _statusChip(req.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topArtisansSection() {
    final artisans = MockData.artisans.take(5).toList();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Top artisans'.tr),
          const SizedBox(height: AppSizes.sm),
          ...artisans.map(
            (artisan) => Container(
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
                    child: const Icon(Icons.person, color: AppColors.text),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artisan.name,
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                        ),
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
                      Text(
                        artisan.rating.toStringAsFixed(1),
                        style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'in progress':
        color = Colors.amber;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
