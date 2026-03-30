import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: 'Dashboard'.tr,
      actions: [
        Obx(() {
          final loading = controller.loading.value;
          return IconButton(
            onPressed: loading ? null : controller.loadDashboard,
            tooltip: 'Refresh'.tr,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.refresh_rounded, color: AppColors.textMuted),
          );
        }),
      ],
      child: Obx(() {
        if (controller.loading.value) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ShimmerGridPlaceholder(count: 4),
              SizedBox(height: AppSizes.lg),
              ShimmerCardPlaceholder(height: 280, lines: 4),
              SizedBox(height: AppSizes.lg),
              ShimmerListPlaceholder(rows: 6, itemHeight: 60),
            ],
          );
        }

        if (controller.error.value != null) {
          return _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: controller.loadDashboard,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text('Refresh'.tr),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.error.value!,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        final stats = controller.stats.value ?? <String, dynamic>{};

        final chartData = _asList(
          stats['monthly'] ?? stats['analytics'] ?? stats['chart'],
        );

        final latestRaw = _asList(stats['latestRequests'] ?? stats['latest']);

        final latestAll = controller.latestRequests.isNotEmpty
            ? controller.latestRequests
            : (latestRaw.isNotEmpty ? latestRaw : controller.activities);

        final latest = _limitLatestRequests(latestAll, 5);
        final topArtisans = controller.topArtisans.isNotEmpty
            ? controller.topArtisans
            : _asList(stats['topArtisans'] ?? stats['top']);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard'.tr,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              'Overview and insights'.tr,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: AppSizes.lg),

            // =========================
            // KPI GRID (fixed layout)
            // =========================
            LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final cols = w >= 1100
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
                  childAspectRatio: cols == 1 ? 3.2 : 2.4,
                  children: _buildKpiCards(context, stats),
                );
              },
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // CHART
            // =========================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _sectionTitle('Monthly performance'.tr)),
                      _pill(icon: Icons.bar_chart, text: 'Requests'.tr),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  SizedBox(
                    height: 280,
                    child: chartData.isEmpty
                        ? Center(
                            child: Text(
                              'No data'.tr,
                              style: TextStyle(color: AppColors.textMuted),
                            ),
                          )
                        : BarChart(_buildBarChartData(chartData)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // LISTS
            // =========================
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

  // =========================================
  // KPI CARDS (new look)
  // =========================================
  List<Widget> _buildKpiCards(
    BuildContext context,
    Map<String, dynamic> stats,
  ) {
    final items = <_KpiItem>[
      _KpiItem(
        title: 'Total Requests'.tr,
        value: _formatNumber(
          stats['totalRequests'] ?? stats['requests'] ?? stats['requestsCount'],
        ),
        icon: Icons.timeline,
        color: AppColors.primary,
        hint: 'All time'.tr,
      ),
      _KpiItem(
        title: 'Completed Requests'.tr,
        value: _formatNumber(
          stats['completedRequests'] ?? stats['completed'] ?? stats['done'],
        ),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
        hint: 'Finished'.tr,
      ),
      _KpiItem(
        title: 'Active Requests'.tr,
        value: _formatNumber(
          stats['activeRequests'] ?? stats['active'] ?? stats['inProgress'],
        ),
        icon: Icons.run_circle_outlined,
        color: Colors.amber.shade700,
        hint: 'In progress'.tr,
      ),
      _KpiItem(
        title: 'Total Earnings'.tr,
        value: _formatMoney(stats['totalEarnings'] ?? stats['earnings'] ?? 0),
        icon: Icons.payments_outlined,
        color: Colors.teal.shade600,
        hint: 'EGP'.tr,
      ),
    ];

    return items.map((it) => _kpiCard(it)).toList();
  }

  Widget _kpiCard(_KpiItem it) {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // icon block
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: it.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(it.icon, color: it.color),
          ),
          const SizedBox(width: AppSizes.md),

          // texts
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  it.value,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.0,
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

          // subtle arrow
          Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }

  // =========================================
  // CHART DATA
  // =========================================
  BarChartData _buildBarChartData(List<dynamic> chartData) {
    double maxVal = 0;

    for (final e in chartData) {
      final v =
          double.tryParse(
            ((e as Map<String, dynamic>?)?['requests'] ?? 0).toString(),
          ) ??
          0;
      maxVal = max(maxVal, v);
    }

    final double maxY = maxVal <= 0 ? 10 : (maxVal + max(10, maxVal * 0.15));

    return BarChartData(
      maxY: maxY,
      minY: 0,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (_) =>
            FlLine(strokeWidth: 1, color: AppColors.border.withOpacity(0.6)),
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipPadding: const EdgeInsets.all(10),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final idx = group.x;
            if (idx < 0 || idx >= chartData.length) return null;
            final item = chartData[idx] as Map<String, dynamic>? ?? {};
            final label = (item['month'] ?? item['label'] ?? '').toString();
            return BarTooltipItem(
              '$label\n${rod.toY.toInt()}',
              TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
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
            interval: maxY / 4,
            reservedSize: 44,
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
              final index = value.toInt();
              if (index < 0 || index >= chartData.length) {
                return const SizedBox.shrink();
              }
              final item = chartData[index] as Map<String, dynamic>? ?? {};
              final label = (item['month'] ?? item['label'] ?? '').toString();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  label.length > 3 ? label.substring(0, 3) : label,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
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
                toY:
                    double.tryParse(
                      ((chartData[i] as Map<String, dynamic>?)?['requests'] ??
                              0)
                          .toString(),
                    ) ??
                    0,
                width: 18,
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

  // =========================================
  // LATEST REQUESTS
  // =========================================
  Widget _latestRequestsSection(List<dynamic> requests) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _sectionTitle('Latest requests'.tr)),
              TextButton(
                onPressed: () => Get.toNamed('/orders'),
                child: Text('View all'.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (requests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              child: Text(
                'No data'.tr,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ...requests.map((raw) {
            final req = raw is Map<String, dynamic>
                ? raw
                : raw is Map
                ? Map<String, dynamic>.from(raw)
                : <String, dynamic>{};
            final createdAt = req['createdAt'] ?? req['created'] ?? req['date'];
            final time = _formatRelativeTime(createdAt);

            final service = _firstText([
              req['serviceType'],
              req['service'],
              req['category']?['name'],
            ], fallback: 'Service'.tr);
            final customerName = _resolveEntityName(req['customer']);
            final artisanName = _resolveEntityName(
              req['artisan'],
              fallback: 'Unknown artisan'.tr,
            );
            final status = (req['status'] ?? '').toString();
            final id = (req['_id'] ?? req['id'] ?? '').toString();

            return InkWell(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              onTap: () {
                if (id.isNotEmpty) {
                  Get.toNamed('/order/details', arguments: req);
                } else {
                  Get.toNamed('/orders');
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSizes.sm),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),

                ),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final compact = c.maxWidth < 560;

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.12,
                                ),
                                child: Icon(
                                  Icons.build,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  service,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (time.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${customerName.isEmpty ? '-' : customerName}  →  ${artisanName.isEmpty ? '-' : artisanName}',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _statusChip(status),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Icon(Icons.build, color: AppColors.primary),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      service,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  if (time.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      time,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${customerName.isEmpty ? '-' : customerName}  →  ${artisanName.isEmpty ? '-' : artisanName}',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSizes.sm),
                        _statusChip(status),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // =========================================
  // TOP ARTISANS
  // =========================================
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
              child: Text(
                'No data'.tr,
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ...artisans.asMap().entries.map((entry) {
            final idx = entry.key;
            final raw = entry.value;
            final artisan = raw is Map<String, dynamic>
                ? raw
                : raw is Map
                ? Map<String, dynamic>.from(raw)
                : <String, dynamic>{};
            final artisanObj = artisan['artisan'];
            final artisanMap = artisanObj is Map<String, dynamic>
                ? artisanObj
                : artisanObj is Map
                ? Map<String, dynamic>.from(artisanObj)
                : <String, dynamic>{};

            final rating =
                double.tryParse(
                  (artisan['avg'] ??
                          artisan['score'] ??
                          artisan['rating'] ??
                          artisanMap['rating'] ??
                          0)
                      .toString(),
                ) ??
                0;

            final artisanId = _firstText([
              artisan['artisanId'],
              artisanMap['_id'],
              artisanMap['id'],
              artisan['_id'],
              artisan['id'],
            ]);

            final name = _firstText([
              artisanMap['name'],
              artisan['name'],
              artisan['artisanName'],
              artisan['userName'],
              artisan['displayName'],
              artisanId,
            ], fallback: 'Unknown artisan'.tr);
            final prof = _firstText([
              artisanMap['profession'],
              artisanMap['service'],
              artisanMap['category']?['name'],
              artisan['profession'],
              artisan['service'],
              artisan['category']?['name'],
            ]);
            final jobsCount = _firstText([
              artisan['count'],
              artisan['requestsCount'],
              artisan['reviewsCount'],
            ]);

            final rank = idx + 1;
            final rankColor = rank == 1
                ? Colors.amber.shade700
                : rank == 2
                ? Colors.blueGrey.shade300
                : rank == 3
                ? Colors.deepOrange.shade300
                : AppColors.textMuted;

            return InkWell(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              onTap: artisanId.isEmpty
                  ? null
                  : () => Get.toNamed(
                      '/artisan/details',
                      arguments: {'_id': artisanId},
                    ),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSizes.sm),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: rankColor.withOpacity(0.55)),
                      ),
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.10),
                      child: Icon(Icons.person, color: AppColors.text),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prof.isEmpty ? '-' : prof,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (jobsCount.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.8),
                          ),
                        ),
                        child: Text(
                          jobsCount,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // =========================================
  // UI HELPERS
  // =========================================
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

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.text,
      fontSize: 16,
      fontWeight: FontWeight.w900,
    ),
  );

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

  // =========================================
  // DATA HELPERS
  // =========================================
  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    if (value is List) return value.cast<dynamic>();
    return [];
  }

  String _firstText(Iterable<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }
    return fallback;
  }

  String _resolveEntityName(dynamic value, {String fallback = ''}) {
    if (value is Map<String, dynamic>) {
      return _firstText([
        value['name'],
        value['fullName'],
        value['username'],
        value['phone'],
        value['_id'],
        value['id'],
      ], fallback: fallback);
    }
    if (value is Map) {
      return _resolveEntityName(
        Map<String, dynamic>.from(value),
        fallback: fallback,
      );
    }
    return _firstText([value], fallback: fallback);
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    if (parsed % 1 == 0) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  String _formatMoney(dynamic value) {
    final n = double.tryParse(value.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    if (n % 1 == 0) return n.toInt().toString();
    return n.toStringAsFixed(1);
  }

  String _formatRelativeTime(dynamic raw) {
    if (raw == null) return '';
    DateTime? dt;

    if (raw is DateTime) {
      dt = raw;
    } else {
      dt = DateTime.tryParse(raw.toString());
    }
    if (dt == null) return '';

    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.isNegative) return 'Now'.tr;

    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return '${weeks}w';
    final months = (diff.inDays / 30).floor();
    return '${months}mo';
  }

  List<dynamic> _limitLatestRequests(List<dynamic> requests, int limit) {
    if (requests.length <= limit) return requests;

    final enriched = requests.map((raw) {
      final map = raw is Map<String, dynamic> ? raw : null;
      final dateValue = map?['createdAt'] ?? map?['created'] ?? map?['date'];
      final parsed = dateValue == null
          ? null
          : DateTime.tryParse(dateValue.toString());
      return (raw, parsed);
    }).toList();

    if (enriched.any((item) => item.$2 != null)) {
      enriched.sort((a, b) {
        final ad = a.$2;
        final bd = b.$2;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    }

    return enriched.take(limit).map((item) => item.$1).toList();
  }

  // =========================================
  // STATUS CHIP (improved mapping)
  // =========================================
  Color _statusColor(String s) {
    final status = s.toLowerCase().trim();

    if (status == 'completed' || status == 'done') return AppColors.success;

    if (status == 'pending' || status == 'new') return AppColors.warning;

    if (status == 'accepted' || status == 'assigned' || status == 'approved') {
      return AppColors.primary;
    }

    if (status == 'in progress' ||
        status == 'in-progress' ||
        status == 'work_started' ||
        status == 'arrived' ||
        status == 'on_the_way') {
      return Colors.amber.shade700;
    }

    if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
      return Colors.redAccent;
    }

    if (status == 'closed') return AppColors.textMuted;

    return AppColors.textMuted;
  }

  Widget _statusChip(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        (status.isEmpty ? '—' : status).tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

// =========================================
// KPI MODEL (local)
// =========================================
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
