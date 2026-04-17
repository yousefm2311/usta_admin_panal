import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class AdminPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget>? actions;
  final List<Widget>? badges;

  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
    this.badges,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 840;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius + 8),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.card,
            AppColors.card,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.05,
            ),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            direction: isCompact ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isCompact
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: isCompact ? 0 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: isCompact ? 22 : 26,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      subtitle.tr,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(height: isCompact ? AppSizes.md : 0),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: actions!,
                ),
              ],
            ],
          ),
          if (badges != null && badges!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.md),
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: badges!,
            ),
          ],
        ],
      ),
    );
  }
}

class AdminInfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const AdminInfoBadge({
    super.key,
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(width: 8),
          Text(
            label.tr,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
