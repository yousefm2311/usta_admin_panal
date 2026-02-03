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
      title: 'System Health'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const _SystemHealthShimmer();
        }

        if (controller.error.value != null) {
          return _StateBox(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong'.tr,
            subtitle: controller.error.value!,
            onRetry: () {
              // لو عندك refresh/load في الكنترولر
              // controller.load();
            },
          );
        }

        final data = controller.health.value ?? <String, dynamic>{};

        final items = [
          SystemHealthItem(
            title: 'API status'.tr,
            value: (data['apiStatus'] ?? '').toString(),
            color: _healthColor((data['apiStatus'] ?? '').toString()),
            icon: Icons.cloud_sync_rounded,
          ),
          SystemHealthItem(
            title: 'Storage'.tr,
            value: (data['storage'] ?? '').toString(),
            color: _healthColor(
              (data['storage'] ?? '').toString(),
              isStorage: true,
            ),
            icon: Icons.storage_rounded,
          ),
          SystemHealthItem(
            title: 'Performance'.tr,
            value: (data['performance'] ?? '').toString(),
            color: _healthColor((data['performance'] ?? '').toString()),
            icon: Icons.speed_rounded,
          ),
        ];

        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;

            // Responsive columns:
            // >= 1100 => 3, >= 760 => 2, else => 1
            final cols = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
            final spacing = AppSizes.md;
            final cardW = (w - (cols - 1) * spacing) / cols;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================
                // Header
                // =========================
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'System Health'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Live status overview'.tr,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    _ActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'Refresh'.tr,
                      onTap: () {
                        // controller.load();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // =========================
                // Grid
                // =========================
                Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items
                      .map(
                        (item) =>
                            SizedBox(width: cardW, child: _HealthCard(item)),
                      )
                      .toList(),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  // =========================
  // Smart coloring by value
  // =========================
  Color _healthColor(String value, {bool isStorage = false}) {
    final v = value.trim().toLowerCase();

    // لو storage ممكن يبقى أرقام/نسبة
    if (isStorage) {
      final numVal = _extractPercentOrNumber(v);
      if (numVal != null) {
        // افتراض: رقم أعلى = استهلاك أعلى
        if (numVal >= 85) return const Color(0xFFDC2626); // red
        if (numVal >= 65) return const Color(0xFFF59E0B); // amber
        return const Color(0xFF16A34A); // green
      }
    }

    if (v.contains('ok') ||
        v.contains('up') ||
        v.contains('healthy') ||
        v.contains('good') ||
        v.contains('online')) {
      return const Color(0xFF16A34A);
    }
    if (v.contains('warn') ||
        v.contains('slow') ||
        v.contains('degraded') ||
        v.contains('medium')) {
      return const Color(0xFFF59E0B);
    }
    if (v.contains('down') ||
        v.contains('fail') ||
        v.contains('error') ||
        v.contains('offline') ||
        v.contains('critical')) {
      return const Color(0xFFDC2626);
    }

    // default
    return AppColors.textMuted;
  }

  double? _extractPercentOrNumber(String v) {
    // يقرأ "78%" أو "78" أو "78.5"
    final cleaned = v.replaceAll('%', '').trim();
    final n = double.tryParse(cleaned);
    return n;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = _statusLabel(item.value);
    final statusBg = item.color.withOpacity(isDark ? 0.18 : 0.12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(isDark ? 0.10 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // top row: icon + badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: item.color.withOpacity(0.25)),
                ),
                child: Icon(item.icon, color: item.color, size: 22),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: item.color.withOpacity(0.30)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            item.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            item.value.isEmpty ? '—' : item.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: item.color == AppColors.textMuted
                  ? AppColors.text
                  : item.color,
            ),
          ),

          const SizedBox(height: 10),

          // small hint line
          Text(
            'Tap to view details'.tr,
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return 'Unknown'.tr;

    if (v.contains('ok') ||
        v.contains('up') ||
        v.contains('healthy') ||
        v.contains('good') ||
        v.contains('online')) {
      return 'Healthy'.tr;
    }
    if (v.contains('warn') ||
        v.contains('slow') ||
        v.contains('degraded') ||
        v.contains('medium')) {
      return 'Warning'.tr;
    }
    if (v.contains('down') ||
        v.contains('fail') ||
        v.contains('error') ||
        v.contains('offline') ||
        v.contains('critical')) {
      return 'Critical'.tr;
    }
    return 'Info'.tr;
  }
}

class _SystemHealthShimmer extends StatelessWidget {
  const _SystemHealthShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
        final spacing = AppSizes.md;
        final cardW = (w - (cols - 1) * spacing) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(
            3,
            (i) => SizedBox(
              width: cardW,
              child: Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 22, width: 44),
                    SizedBox(height: 14),
                    ShimmerBox(height: 14, width: 120),
                    SizedBox(height: 10),
                    ShimmerBox(height: 22, width: 160),
                    SizedBox(height: 14),
                    ShimmerBox(height: 12, width: 140),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================
// Shared small widgets
// =========================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.text),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _StateBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSizes.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}
