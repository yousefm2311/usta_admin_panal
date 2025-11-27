import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: 'Dashboard',
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

        final stats = controller.stats.value ?? <String, dynamic>{};
        final chartData = (stats['monthly'] ?? stats['analytics'] ?? stats['chart'] ?? []) as List<dynamic>;
        // normalize latest requests to avoid mixed data
        final latestRaw = (stats['latestRequests'] ?? stats['latest'] ?? []) as List<dynamic>;
        final latest = controller.latestRequests.isNotEmpty
            ? controller.latestRequests
            : (latestRaw.isNotEmpty ? latestRaw : controller.activities);
        final topArtisans = controller.topArtisans;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: _buildStatCards(context, stats),
            ),
            const SizedBox(height: AppSizes.lg),
            _sectionTitle('Monthly performance'.tr),
            const SizedBox(height: AppSizes.sm),
            _card(
              child: SizedBox(
                height: 280,
                child: chartData.isEmpty
                    ? Center(child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)))
                    : BarChart(
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
                                  if (index < 0 || index >= chartData.length) return const SizedBox.shrink();
                                  final item = chartData[index] as Map<String, dynamic>? ?? {};
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      (item['month'] ?? item['label'] ?? '').toString(),
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            for (var i = 0; i < chartData.length; i++)
                              BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: double.tryParse(
                                          ((chartData[i] as Map<String, dynamic>?)?['requests'] ?? 0).toString(),
                                        ) ??
                                        0,
                                    color: AppColors.primary,
                                    width: 18,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              ),
                          ],
                          maxY: (chartData
                                      .map((e) => double.tryParse(
                                            ((e as Map<String, dynamic>?)?['requests'] ?? 0).toString(),
                                          ) ??
                                          0)
                                      .fold<double>(0, max) +
                                  30)
                              .toDouble(),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSizes.lg),
            if (isMobile)
              Column(
                children: [
                  _latestRequestsSection(latest),
                  const SizedBox(height: AppSizes.md),
                  _topArtisansSection(topArtisans),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _latestRequestsSection(latest)),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: _topArtisansSection(topArtisans)),
                ],
              ),
          ],
        );
      }),
    );
  }

  List<Widget> _buildStatCards(BuildContext context, Map<String, dynamic> stats) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final cardWidth = isDesktop
        ? (MediaQuery.of(context).size.width - 400) / 4
        : isTablet
            ? (MediaQuery.of(context).size.width - 220) / 2
            : MediaQuery.of(context).size.width - 48;

    final List<(String title, String value, Color color, IconData icon)> cards = [
      (
        'Total Requests'.tr,
        _formatNumber(stats['totalRequests'] ?? stats['requests'] ?? stats['requestsCount']),
        AppColors.primary,
        Icons.timeline
      ),
      (
        'Completed Requests'.tr,
        _formatNumber(stats['completedRequests'] ?? stats['completed'] ?? stats['done']),
        AppColors.success,
        Icons.check_circle_outline
      ),
      (
        'Active Requests'.tr,
        _formatNumber(stats['activeRequests'] ?? stats['active'] ?? stats['inProgress']),
        Colors.amber,
        Icons.run_circle_outlined
      ),
      (
        'Total Earnings'.tr,
        stats['totalEarnings']?.toString() ?? stats['earnings']?.toString() ?? '0',
        Colors.tealAccent,
        Icons.payments_outlined
      ),
    ];

    return cards
        .map(
          (s) => SizedBox(
            width: cardWidth < 220 ? double.infinity : cardWidth,
            child: _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    s.$2,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.$1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _latestRequestsSection(List<dynamic> requests) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Latest requests'.tr),
          const SizedBox(height: AppSizes.sm),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
            ),
          ...requests.map(
            (raw) {
              final req = raw as Map<String, dynamic>? ?? {};
              return Container(
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
                            (req['serviceType'] ?? req['service'] ?? '').toString(),
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(req['customer'] ?? req['customerName'] ?? '').toString()} · ${(req['artisan'] ?? req['artisanName'] ?? '').toString()}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _statusChip((req['status'] ?? '').toString()),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _topArtisansSection(List<dynamic> artisans) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Top artisans'.tr),
          const SizedBox(height: AppSizes.sm),
          if (artisans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
            ),
          ...artisans.map(
            (raw) {
              final artisan = raw as Map<String, dynamic>? ?? {};
              final rating = double.tryParse((artisan['rating'] ?? artisan['score'] ?? 0).toString()) ?? 0;
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
                      child: const Icon(Icons.person, color: AppColors.text),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (artisan['name'] ?? artisan['fullName'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            (artisan['category'] ?? artisan['profession'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
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

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    if (parsed % 1 == 0) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'pending':
        color = AppColors.warning;
        break;
      case 'accepted':
        color = Colors.lightBlueAccent;
        break;
      case 'in progress':
      case 'in-progress':
        color = Colors.amber;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
