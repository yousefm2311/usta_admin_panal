import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../navigation/admin_navigation.dart';

class Sidebar extends StatefulWidget {
  final bool collapsed;
  final ValueChanged<String>? onNavigate;

  const Sidebar({super.key, this.collapsed = false, this.onNavigate});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with TickerProviderStateMixin {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final sections = AdminNavigation.sections;
    final currentItem = AdminNavigation.findItem(Get.currentRoute);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: widget.collapsed
          ? AppSizes.sidebarCollapsed
          : AppSizes.sidebarWidth,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.96),
        border: BorderDirectional(end: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.24 : 0.05),
            blurRadius: 30,
            offset: const Offset(8, 0),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          _buildBrandHeader(currentItem),
          const SizedBox(height: AppSizes.sm),
          if (widget.collapsed)
            ..._buildCollapsedItems(sections)
          else
            ..._buildExpandedSections(sections),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(AdminNavItem? currentItem) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.cardRadius + 4),
        border: Border.all(color: AppColors.border.withOpacity(0.9)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary.withOpacity(0.12), AppColors.card],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.25),
                  ),
                ),
                child: Icon(Icons.shield_moon, color: AppColors.primary),
              ),
              if (!widget.collapsed) ...[
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USTA Platform'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Operations Console'.tr,
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (!widget.collapsed) ...[
            const SizedBox(height: AppSizes.md),
            Text(
              'Now viewing'.tr,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (currentItem?.title ?? 'Dashboard').tr,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildExpandedSections(List<AdminNavSection> sections) {
    return [for (final section in sections) _buildSection(section)];
  }

  List<Widget> _buildCollapsedItems(List<AdminNavSection> sections) {
    final items = sections.expand((s) => s.items).toList();

    return [
      for (final item in items)
        Builder(
          builder: (context) {
            final isActive = item.matches(Get.currentRoute);

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: Tooltip(
                message: item.title,
                preferBelow: false,
                child: _HoverTap(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _handleTap(item.route),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary.withOpacity(0.55)
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    ];
  }

  Widget _buildSection(AdminNavSection section) {
    final expanded = _expanded[section.title] ?? _isSectionActive(section);
    final isActiveSection = _isSectionActive(section);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        children: [
          _HoverTap(
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            onTap: () => setState(() => _expanded[section.title] = !expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isActiveSection
                    ? AppColors.primary.withOpacity(0.10)
                    : AppColors.overlay,
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                border: Border.all(
                  color: isActiveSection
                      ? AppColors.primary.withOpacity(0.45)
                      : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    section.icon,
                    color: isActiveSection ? AppColors.primary : AppColors.text,
                    size: 18,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: expanded ? 0.5 : 0.0,
                    child: Icon(
                      Icons.expand_more,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Column(
                      children: [
                        for (final item in section.items) _buildItem(item),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(AdminNavItem item) {
    final isActive = item.matches(Get.currentRoute);

    final indicator = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 4,
      height: 26,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.55)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          indicator,
          const SizedBox(width: 10),
          Icon(
            item.icon,
            color: isActive ? AppColors.primary : AppColors.textMuted,
            size: 20,
          ),
          if (!widget.collapsed) ...[
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? AppColors.text : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted.withOpacity(0.9),
              size: 18,
            ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: _HoverTap(
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        onTap: () => _handleTap(item.route),
        child: content,
      ),
    );
  }

  void _handleTap(String route) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      if (Get.currentRoute != route) {
        Get.offNamed(route);
      }
    }
  }

  bool _isSectionActive(AdminNavSection section) {
    return section.items.any((item) => item.matches(Get.currentRoute));
  }
}

class _HoverTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _HoverTap({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_HoverTap> createState() => _HoverTapState();
}

class _HoverTapState extends State<_HoverTap> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lift = _hover ? -1.5 : 0.0;
    final scale = _down ? 0.99 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, lift)
            ..scale(scale),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
