import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class Sidebar extends StatelessWidget {
  final bool collapsed;
  final ValueChanged<String>? onNavigate;

  const Sidebar({
    super.key,
    this.collapsed = false,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _SidebarItem('Dashboard'.tr, Icons.space_dashboard_outlined, '/dashboard'),
      _SidebarItem('Customers'.tr, Icons.people_alt_outlined, '/customers'),
      _SidebarItem('Artisans'.tr, Icons.handyman, '/artisans'),
      _SidebarItem('Requests'.tr, Icons.list_alt_outlined, '/requests'),
      _SidebarItem('Payments'.tr, Icons.payments_outlined, '/payments'),
      _SidebarItem('Withdrawals'.tr, Icons.account_balance_wallet_outlined, '/withdrawals'),
      _SidebarItem('Categories'.tr, Icons.category_outlined, '/categories'),
      _SidebarItem('Reviews'.tr, Icons.star_half, '/reviews'),
      _SidebarItem('Notifications'.tr, Icons.notifications_none, '/notifications'),
      _SidebarItem('Analytics'.tr, Icons.analytics_outlined, '/analytics'),
      _SidebarItem('AI Tools'.tr, Icons.auto_awesome, '/ai/reviews'),
      _SidebarItem('Settings'.tr, Icons.settings_outlined, '/settings'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: collapsed ? AppSizes.sidebarCollapsed : AppSizes.sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_moon, color: AppColors.primary),
                ),
                if (!collapsed) ...[
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'USTA Platform'.tr,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          for (final item in items) _buildItem(item),
        ],
      ),
    );
  }

  Widget _buildItem(_SidebarItem item) {
    final current = Get.currentRoute;
    final isActive = current == item.route || current.startsWith('${item.route}/');

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: AppColors.text, size: 20),
          if (!collapsed) ...[
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textMuted,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: collapsed
          ? Tooltip(
              message: item.title,
              preferBelow: false,
              child: InkWell(
                onTap: () => _handleTap(item.route),
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                child: SizedBox(
                  height: 48,
                  child: Center(child: Icon(item.icon, color: AppColors.textMuted)),
                ),
              ),
            )
          : InkWell(
              onTap: () => _handleTap(item.route),
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              child: content,
            ),
    );
  }

  void _handleTap(String route) {
    if (onNavigate != null) {
      onNavigate!(route);
    } else {
      Get.offAllNamed(route);
    }
  }
}

class _SidebarItem {
  final String title;
  final IconData icon;
  final String route;

  _SidebarItem(this.title, this.icon, this.route);
}
