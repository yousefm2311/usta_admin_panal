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
              ShimmerGridPlaceholder(count: 4),
              SizedBox(height: AppSizes.lg),
              ShimmerCardPlaceholder(height: 280, lines: 4),
              SizedBox(height: AppSizes.md),
              ShimmerCardPlaceholder(height: 280, lines: 4),
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
        final revenue = controller.revenue.value;
        final activeUsers = controller.activeUsers.value;

        final maxRequests = _maxOf(data, 'requests');
        final maxEarnings = _maxOf(data, 'earnings');

        final revenueTotal = _extractNumber(revenue, [
          'total',
          'revenue',
          'amount',
          'value',
          'sum',
        ]);
        final activeCount = _extractNumber(activeUsers, [
          'activeUsers',
          'active',
          'count',
          'total',
        ]);

        final currentRequests = _currentMonthValue(data, 'requests');
        final currentEarnings = _currentMonthValue(data, 'earnings');
        final avgRating = controller.avgRating.value;

        // KPI items
        final kpis = <_KpiItem>[
          _KpiItem(
            title: 'Requests this month'.tr,
            value: _fmtNum((currentRequests ?? maxRequests).toDouble()),
            icon: Icons.timeline,
            color: AppColors.primary,
            hint: 'Month'.tr,
          ),
          _KpiItem(
            title: 'Earnings this month'.tr,
            value:
                'EG ${_fmtMoney((currentEarnings ?? maxEarnings).toDouble())}',
            icon: Icons.trending_up,
            color: AppColors.success,
            hint: 'Month'.tr,
          ),
          _KpiItem(
            title: 'Total revenue'.tr,
            value: revenueTotal == null ? '-' : 'EG ${_fmtMoney(revenueTotal)}',
            icon: Icons.account_balance_wallet_outlined,
            color: Colors.teal.shade600,
            hint: 'All time'.tr,
          ),
          _KpiItem(
            title: 'Active users'.tr,
            value: activeCount == null ? '-' : _fmtNum(activeCount),
            icon: Icons.people_outline,
            color: Colors.amber.shade700,
            hint: 'Now'.tr,
          ),
          _KpiItem(
            title: 'Avg. rating'.tr,
            value: avgRating == null ? '-' : avgRating.toStringAsFixed(1),
            icon: Icons.star,
            color: Colors.deepOrangeAccent,
            hint: 'All time'.tr,
          ),
        ];

        final charts = <Widget>[
          _chartCard(
            title: 'Requests per month'.tr,
            subtitle: 'Total requests trend'.tr,
            trailing: _pill(icon: Icons.bar_chart, text: 'Requests'.tr),
            child: data.isEmpty
                ? _emptyChart()
                : BarChart(_buildRequestsBar(data)),
          ),
          _chartCard(
            title: 'Earnings per month'.tr,
            subtitle: 'Revenue trend'.tr,
            trailing: _pill(icon: Icons.show_chart, text: 'Earnings'.tr),
            child: data.isEmpty
                ? _emptyChart()
                : LineChart(_buildEarningsLine(data)),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytics'.tr,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Insights & performance'.tr,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: AppSizes.lg),

            // KPI GRID
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 1100
                    ? 5
                    : w >= 900
                    ? 4
                    : w >= 700
                    ? 2
                    : 1;

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  crossAxisSpacing: AppSizes.md,
                  mainAxisSpacing: AppSizes.md,
                  childAspectRatio: cols == 1 ? 3.2 : 2.35,
                  children: kpis.map(_kpiCard).toList(),
                );
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // CHARTS
            if (isMobile)
              Column(
                children: [
                  charts[0],
                  const SizedBox(height: AppSizes.md),
                  charts[1],
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: charts[0]),
                  const SizedBox(width: AppSizes.md),
                  Expanded(child: charts[1]),
                ],
              ),
          ],
        );
      }),
    );
  }

  // ======================================================
  // KPI CARD
  // ======================================================
  Widget _kpiCard(_KpiItem it) {
    return _card(
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: it.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(it.icon, color: it.color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  it.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: it.color),
                    const SizedBox(width: 6),
                    Text(
                      it.hint,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // CHARTS (Requests Bar)
  // ======================================================
  BarChartData _buildRequestsBar(List<dynamic> data) {
    double maxVal = 0;
    for (final raw in data) {
      final item = raw is Map<String, dynamic> ? raw : null;
      final v = double.tryParse((item?['requests'] ?? 0).toString()) ?? 0;
      maxVal = max(maxVal, v);
    }
    final double maxY = maxVal <= 0 ? 10 : (maxVal + max(10, maxVal * 0.15));
    final interval = maxY / 4;

    return BarChartData(
      maxY: maxY,
      minY: 0,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval <= 0 ? 1 : interval,
        getDrawingHorizontalLine: (_) =>
            FlLine(strokeWidth: 1, color: AppColors.border.withOpacity(0.6)),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(10),
          tooltipMargin: 10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final idx = group.x;
            if (idx < 0 || idx >= data.length) return null;
            final item = data[idx] as Map<String, dynamic>? ?? {};
            final label = (item['month'] ?? item['label'] ?? '').toString();
            return BarTooltipItem(
              '$label\n${rod.toY.toInt()}',
              TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44,
            interval: interval <= 0 ? 1 : interval,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              if (idx < 0 || idx >= data.length) {
                return const SizedBox.shrink();
              }
              final item = data[idx] as Map<String, dynamic>? ?? {};
              final label = (item['month'] ?? '').toString();
              final short = label.length > 3 ? label.substring(0, 3) : label;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  short,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
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
                toY:
                    (double.tryParse((data[i]['requests'] ?? 0).toString()) ??
                    0),
                width: 16,
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: AppColors.border.withOpacity(0.18),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ======================================================
  // CHARTS (Earnings Line)
  // ======================================================
  LineChartData _buildEarningsLine(List<dynamic> data) {
    double maxVal = 0;
    for (final raw in data) {
      final item = raw is Map<String, dynamic> ? raw : null;
      final v = double.tryParse((item?['earnings'] ?? 0).toString()) ?? 0;
      maxVal = max(maxVal, v);
    }
    final double maxY = maxVal <= 0 ? 100 : (maxVal + max(100, maxVal * 0.15));
    final interval = maxY / 4;

    return LineChartData(
      minX: 0,
      maxX: max(0, data.length - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: interval <= 0 ? 1 : interval,
        getDrawingHorizontalLine: (_) =>
            FlLine(strokeWidth: 1, color: AppColors.border.withOpacity(0.6)),
      ),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(10),
          tooltipMargin: 10,
          getTooltipItems: (spots) {
            return spots.map((s) {
              final idx = s.x.toInt();
              final label = (idx >= 0 && idx < data.length)
                  ? (data[idx]['month'] ?? '').toString()
                  : '';
              return LineTooltipItem(
                '$label\nEG ${s.y.toStringAsFixed(0)}',
                TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 54,
            interval: interval <= 0 ? 1 : interval,
            getTitlesWidget: (value, _) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, _) {
              final idx = value.toInt();
              if (idx < 0 || idx >= data.length) {
                return const SizedBox.shrink();
              }
              final label = (data[idx]['month'] ?? '').toString();
              final short = label.length > 3 ? label.substring(0, 3) : label;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  short,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          curveSmoothness: 0.25,
          barWidth: 3,
          color: AppColors.success,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.success.withOpacity(0.12),
          ),
          spots: [
            for (var i = 0; i < data.length; i++)
              FlSpot(
                i.toDouble(),
                double.tryParse((data[i]['earnings'] ?? 0).toString()) ?? 0,
              ),
          ],
        ),
      ],
    );
  }

  // ======================================================
  // UI SHELLS
  // ======================================================
  Widget _chartCard({
    required String title,
    String? subtitle,
    Widget? trailing,
    required Widget child,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          SizedBox(height: 280, child: child),
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
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _pill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChart() {
    return Center(
      child: Text('No data'.tr, style: TextStyle(color: AppColors.textMuted)),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================
  double _maxOf(List<dynamic> data, String key) {
    if (data.isEmpty) return 0;
    double m = 0;
    for (final raw in data) {
      final item = raw is Map<String, dynamic> ? raw : null;
      final v = double.tryParse((item?[key] ?? 0).toString()) ?? 0;
      m = max(m, v);
    }
    return m;
  }

  double? _extractNumber(Map<String, dynamic>? data, List<String> keys) {
    if (data == null) return null;
    for (final key in keys) {
      final value = data[key];
      if (value == null) continue;
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return null;
  }

  double? _currentMonthValue(List<dynamic> data, String key) {
    if (data.isEmpty) return null;
    final now = DateTime.now();

    // If you store monthIndex as 1..12 and year as int
    for (final raw in data) {
      final item = raw is Map<String, dynamic> ? raw : null;
      if (item == null) continue;

      final monthIndex = item['monthIndex'];
      final year = item['year'];

      if (monthIndex is int && year is int) {
        if (monthIndex == now.month && year == now.year) {
          return double.tryParse((item[key] ?? 0).toString());
        }
      }
    }

    // fallback latest
    final last = data.last;
    if (last is Map<String, dynamic>) {
      return double.tryParse((last[key] ?? 0).toString());
    }
    return null;
  }

  String _fmtNum(double n) {
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  String _fmtMoney(double n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }
}

class _KpiItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String hint;

  _KpiItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.hint,
  });
}
