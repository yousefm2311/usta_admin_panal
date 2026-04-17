import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AdminBreadcrumbItem {
  final String label;
  final String? route;

  const AdminBreadcrumbItem({required this.label, this.route});
}

class AdminBreadcrumbs extends StatelessWidget {
  final List<AdminBreadcrumbItem> items;

  const AdminBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _BreadcrumbChip(item: items[i], current: i == items.length - 1),
          if (i != items.length - 1)
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
        ],
      ],
    );
  }
}

class _BreadcrumbChip extends StatelessWidget {
  final AdminBreadcrumbItem item;
  final bool current;

  const _BreadcrumbChip({required this.item, required this.current});

  @override
  Widget build(BuildContext context) {
    final accent = current ? AppColors.primary : AppColors.textMuted;

    return InkWell(
      onTap: item.route == null || current
          ? null
          : () => Get.offNamed(item.route!),
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: current
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.overlay,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: current
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.border.withOpacity(0.8),
          ),
        ),
        child: Text(
          item.label.tr,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: current ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AdminSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget>? actions;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AdminSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.actions,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.18),
                    ),
                  ),
                  child: Icon(icon, color: AppColors.primary),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!.tr,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty)
                Wrap(spacing: 8, runSpacing: 8, children: actions!),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          child,
        ],
      ),
    );
  }
}

class AdminStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const AdminStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.tr,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
