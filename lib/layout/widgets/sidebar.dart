import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

class Sidebar extends StatefulWidget {
  final bool collapsed;
  final ValueChanged<String>? onNavigate;

  const Sidebar({
    super.key,
    this.collapsed = false,
    this.onNavigate,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> with TickerProviderStateMixin {
  final Map<String, bool> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final sections = _sections();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.collapsed ? AppSizes.sidebarCollapsed : AppSizes.sidebarWidth,
      decoration: BoxDecoration(
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
                  child: Icon(Icons.shield_moon, color: AppColors.primary),
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'USTA Platform'.tr,
                    style: TextStyle(
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
          if (widget.collapsed) ..._buildCollapsedItems(sections) else ..._buildExpandedSections(sections),
        ],
      ),
    );
  }

  List<_SidebarSection> _sections() {
    return [
      _SidebarSection(
        title: 'Main'.tr,
        icon: Icons.home_outlined,
        items: [
          _SidebarItem('Dashboard'.tr, Icons.space_dashboard_outlined, '/dashboard'),
          _SidebarItem('Analytics'.tr, Icons.analytics_outlined, '/analytics'),
        ],
      ),
      _SidebarSection(
        title: 'Users'.tr,
        icon: Icons.people_alt_outlined,
        items: [
          _SidebarItem('Customers'.tr, Icons.people_alt_outlined, '/customers'),
          _SidebarItem('Artisans'.tr, Icons.handyman, '/artisans'),
          _SidebarItem('Roles'.tr, Icons.admin_panel_settings_outlined, '/roles'),
          _SidebarItem('Profile'.tr, Icons.account_circle_outlined, '/profile'),
        ],
      ),
      _SidebarSection(
        title: 'Orders'.tr,
        icon: Icons.shopping_bag_outlined,
        items: [
          _SidebarItem('Orders'.tr, Icons.shopping_bag_outlined, '/orders'),
          _SidebarItem('Requests'.tr, Icons.list_alt_outlined, '/requests'),
          _SidebarItem('Complaints'.tr, Icons.support_agent, '/complaints'),
          _SidebarItem('Reviews'.tr, Icons.star_half, '/reviews'),
        ],
      ),
      _SidebarSection(
        title: 'Finance'.tr,
        icon: Icons.account_balance_wallet_outlined,
        items: [
          _SidebarItem('Payments'.tr, Icons.payments_outlined, '/payments'),
          _SidebarItem('Transactions'.tr, Icons.swap_horiz, '/transactions'),
          _SidebarItem('Payout Requests'.tr, Icons.payments_outlined, '/payouts'),
          _SidebarItem('Withdrawals'.tr, Icons.account_balance_wallet_outlined, '/withdrawals'),
          _SidebarItem('Wallets'.tr, Icons.account_balance, '/wallets'),
        ],
      ),
      _SidebarSection(
        title: 'Content'.tr,
        icon: Icons.category_outlined,
        items: [
          _SidebarItem('Categories'.tr, Icons.category_outlined, '/categories'),
          _SidebarItem('Reports'.tr, Icons.report_outlined, '/reports'),
        ],
      ),
      _SidebarSection(
        title: 'Notifications'.tr,
        icon: Icons.notifications_none,
        items: [
          _SidebarItem('Notifications'.tr, Icons.notifications_none, '/notifications'),
          _SidebarItem('Templates'.tr, Icons.note_outlined, '/notifications/templates'),
          _SidebarItem('Broadcast'.tr, Icons.campaign_outlined, '/notifications/broadcast'),
          _SidebarItem('FCM Tokens'.tr, Icons.phonelink_ring_outlined, '/notifications/tokens'),
        ],
      ),
      _SidebarSection(
        title: 'Marketing'.tr,
        icon: Icons.campaign_outlined,
        items: [
          _SidebarItem('Coupons'.tr, Icons.local_offer_outlined, '/marketing/coupons'),
          _SidebarItem('Referral'.tr, Icons.share_outlined, '/marketing/referral'),
          _SidebarItem('Rewards'.tr, Icons.emoji_events_outlined, '/marketing/rewards'),
        ],
      ),
      _SidebarSection(
        title: 'AI Tools'.tr,
        icon: Icons.auto_awesome,
        items: [
          _SidebarItem('AI Reviews Insights'.tr, Icons.auto_awesome, '/ai/reviews'),
          _SidebarItem('AI Top Artisans'.tr, Icons.emoji_events_outlined, '/ai/top-artisans'),
          _SidebarItem('Fraud detection'.tr, Icons.gpp_maybe_outlined, '/ai/fraud'),
          _SidebarItem('Word cloud'.tr, Icons.cloud_outlined, '/ai/word-cloud'),
        ],
      ),
      _SidebarSection(
        title: 'Settings'.tr,
        icon: Icons.settings_outlined,
        items: [
          _SidebarItem('Settings'.tr, Icons.settings_outlined, '/settings'),
          _SidebarItem('Feature flags'.tr, Icons.tune, '/settings/features'),
          _SidebarItem('Security'.tr, Icons.security_outlined, '/settings/security'),
          _SidebarItem('Change password'.tr, Icons.lock_reset_outlined, '/settings/change-password'),
        ],
      ),
      _SidebarSection(
        title: 'System'.tr,
        icon: Icons.monitor_heart_outlined,
        items: [
          _SidebarItem('Logs'.tr, Icons.list_alt_outlined, '/logs/activity'),
          _SidebarItem('System Health'.tr, Icons.health_and_safety_rounded, '/logs/health'),
        ],
      ),
    ];
  }

  List<Widget> _buildExpandedSections(List<_SidebarSection> sections) {
    return [
      for (final section in sections) _buildSection(section),
    ];
  }

  List<Widget> _buildCollapsedItems(List<_SidebarSection> sections) {
    final items = sections.expand((s) => s.items).toList();
    return [
      for (final item in items)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSizes.sm),
          child: Tooltip(
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
          ),
        ),
    ];
  }

  Widget _buildSection(_SidebarSection section) {
    final expanded = _expanded[section.title] ?? _isSectionActive(section);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded[section.title] = !expanded),
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: expanded ? AppColors.primary.withOpacity(0.08) : AppColors.overlay,
                borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(section.icon, color: AppColors.text, size: 18),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSizes.sm),
                    child: Column(
                      children: [for (final item in section.items) _buildItem(item)],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
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
          if (!widget.collapsed) ...[
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
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 16),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: InkWell(
        onTap: () => _handleTap(item.route),
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        child: content,
      ),
    );
  }

  void _handleTap(String route) {
    if (widget.onNavigate != null) {
      widget.onNavigate!(route);
    } else {
      Get.offAllNamed(route);
    }
  }

  bool _isSectionActive(_SidebarSection section) {
    final current = Get.currentRoute;
    return section.items.any(
      (item) => current == item.route || current.startsWith('${item.route}/'),
    );
  }
}

class _SidebarItem {
  final String title;
  final IconData icon;
  final String route;

  _SidebarItem(this.title, this.icon, this.route);
}

class _SidebarSection {
  final String title;
  final IconData icon;
  final List<_SidebarItem> items;

  _SidebarSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}
