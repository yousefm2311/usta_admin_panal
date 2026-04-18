import 'package:flutter/material.dart';

class AdminNavigation {
  static List<AdminNavSection> get sections => [
    AdminNavSection(
      title: 'Main',
      icon: Icons.home_outlined,
      items: [
        AdminNavItem(
          title: 'Dashboard',
          icon: Icons.space_dashboard_outlined,
          route: '/dashboard',
        ),
        AdminNavItem(
          title: 'Analytics',
          icon: Icons.analytics_outlined,
          route: '/analytics',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Users',
      icon: Icons.people_alt_outlined,
      items: [
        AdminNavItem(
          title: 'Customers',
          icon: Icons.people_alt_outlined,
          route: '/customers',
          routeMatches: const [
            '/customers',
            '/customer/details',
            '/customer/orders',
          ],
        ),
        AdminNavItem(
          title: 'Artisans',
          icon: Icons.handyman,
          route: '/artisans',
          routeMatches: const ['/artisans', '/artisan/details'],
        ),
        AdminNavItem(
          title: 'Roles',
          icon: Icons.admin_panel_settings_outlined,
          route: '/roles',
          routeMatches: const ['/roles', '/roles/permissions'],
        ),
        AdminNavItem(
          title: 'Profile',
          icon: Icons.account_circle_outlined,
          route: '/profile',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Operations',
      icon: Icons.shopping_bag_outlined,
      items: [
        AdminNavItem(
          title: 'Orders',
          icon: Icons.shopping_bag_outlined,
          route: '/orders',
          routeMatches: const ['/orders', '/order/details', '/order/timeline'],
        ),
        AdminNavItem(
          title: 'Requests',
          icon: Icons.list_alt_outlined,
          route: '/requests',
          routeMatches: const ['/requests', '/request/details'],
        ),
        AdminNavItem(
          title: 'Complaints',
          icon: Icons.support_agent,
          route: '/complaints',
          routeMatches: const ['/complaints', '/complaint/details'],
        ),
        AdminNavItem(
          title: 'Reviews',
          icon: Icons.star_half,
          route: '/reviews',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      items: [
        AdminNavItem(
          title: 'Payments',
          icon: Icons.payments_outlined,
          route: '/payments',
          routeMatches: const ['/payments', '/payment/details'],
        ),
        AdminNavItem(
          title: 'Transactions',
          icon: Icons.swap_horiz,
          route: '/transactions',
        ),
        AdminNavItem(
          title: 'Payout Requests',
          icon: Icons.payments_outlined,
          route: '/payouts',
          routeMatches: const ['/payouts', '/payout/details'],
        ),
        AdminNavItem(
          title: 'Withdrawals',
          icon: Icons.account_balance_wallet_outlined,
          route: '/withdrawals',
        ),
        AdminNavItem(
          title: 'Wallets',
          icon: Icons.account_balance,
          route: '/wallets',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Content',
      icon: Icons.category_outlined,
      items: [
        AdminNavItem(
          title: 'Categories',
          icon: Icons.category_outlined,
          route: '/categories',
          routeMatches: const ['/categories', '/category/add'],
        ),
        AdminNavItem(
          title: 'Reports',
          icon: Icons.report_outlined,
          route: '/reports',
          routeMatches: const ['/reports', '/report/details'],
        ),
      ],
    ),
    AdminNavSection(
      title: 'Messaging',
      icon: Icons.notifications_none,
      items: [
        AdminNavItem(
          title: 'Notifications',
          icon: Icons.notifications_none,
          route: '/notifications',
          routeMatches: const ['/notifications', '/notifications/send'],
        ),
        AdminNavItem(
          title: 'Templates',
          icon: Icons.note_outlined,
          route: '/notifications/templates',
        ),
        AdminNavItem(
          title: 'Broadcast',
          icon: Icons.campaign_outlined,
          route: '/notifications/broadcast',
        ),
        AdminNavItem(
          title: 'FCM Tokens',
          icon: Icons.phonelink_ring_outlined,
          route: '/notifications/tokens',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Growth',
      icon: Icons.campaign_outlined,
      items: [
        AdminNavItem(
          title: 'Coupons',
          icon: Icons.local_offer_outlined,
          route: '/marketing/coupons',
        ),
        AdminNavItem(
          title: 'Referral',
          icon: Icons.share_outlined,
          route: '/marketing/referral',
        ),
        AdminNavItem(
          title: 'Rewards',
          icon: Icons.emoji_events_outlined,
          route: '/marketing/rewards',
        ),
      ],
    ),
    AdminNavSection(
      title: 'AI Tools',
      icon: Icons.auto_awesome,
      items: [
        AdminNavItem(
          title: 'AI Reviews Insights',
          icon: Icons.auto_awesome,
          route: '/ai/reviews',
        ),
        AdminNavItem(
          title: 'AI Top Artisans',
          icon: Icons.emoji_events_outlined,
          route: '/ai/top-artisans',
        ),
        AdminNavItem(
          title: 'Fraud detection',
          icon: Icons.gpp_maybe_outlined,
          route: '/ai/fraud',
        ),
        AdminNavItem(
          title: 'Word cloud',
          icon: Icons.cloud_outlined,
          route: '/ai/word-cloud',
        ),
      ],
    ),
    AdminNavSection(
      title: 'Settings',
      icon: Icons.settings_outlined,
      items: [
        AdminNavItem(
          title: 'Settings',
          icon: Icons.settings_outlined,
          route: '/settings',
        ),
        AdminNavItem(
          title: 'Feature flags',
          icon: Icons.tune,
          route: '/settings/features',
        ),
        AdminNavItem(
          title: 'Security',
          icon: Icons.security_outlined,
          route: '/settings/security',
        ),
        AdminNavItem(
          title: 'Change password',
          icon: Icons.lock_reset_outlined,
          route: '/settings/change-password',
        ),
      ],
    ),
    AdminNavSection(
      title: 'System',
      icon: Icons.monitor_heart_outlined,
      items: [
        AdminNavItem(
          title: 'Logs',
          icon: Icons.list_alt_outlined,
          route: '/logs/activity',
        ),
        AdminNavItem(
          title: 'System Health',
          icon: Icons.health_and_safety_rounded,
          route: '/logs/health',
        ),
      ],
    ),
  ];

  static AdminNavItem? findItem(String route) {
    for (final section in sections) {
      for (final item in section.items) {
        if (item.matches(route)) return item;
      }
    }
    return null;
  }

  static AdminNavSection? findSection(String route) {
    for (final section in sections) {
      if (section.items.any((item) => item.matches(route))) {
        return section;
      }
    }
    return null;
  }

  static String titleForRoute(String route) {
    const customTitles = <String, String>{
      '/login': 'Login',
      '/reset': 'Reset Password',
      '/choose-role': 'Choose Role',
      '/order/details': 'Order Details',
      '/order/timeline': 'Order Timeline',
      '/customer/details': 'Customer Details',
      '/customer/orders': 'Customer Orders',
      '/artisan/details': 'Artisan Details',
      '/request/details': 'Request Details',
      '/payment/details': 'Payment Details',
      '/payout/details': 'Payout Details',
      '/report/details': 'Report Details',
      '/complaint/details': 'Complaint Details',
      '/notifications/send': 'Send Notification',
      '/category/add': 'Add Category',
      '/roles/permissions': 'Role Permissions',
    };

    return customTitles[route] ?? findItem(route)?.title ?? 'Admin Panel';
  }

  static String sectionTitleForRoute(String route) {
    return findSection(route)?.title ?? 'Workspace';
  }
}

class AdminNavSection {
  final String title;
  final IconData icon;
  final List<AdminNavItem> items;

  const AdminNavSection({
    required this.title,
    required this.icon,
    required this.items,
  });
}

class AdminNavItem {
  final String title;
  final IconData icon;
  final String route;
  final List<String> routeMatches;

  const AdminNavItem({
    required this.title,
    required this.icon,
    required this.route,
    List<String>? routeMatches,
  }) : routeMatches = routeMatches ?? const [];

  bool matches(String currentRoute) {
    final candidates = {route, ...routeMatches};
    return candidates.any(
      (candidate) =>
          currentRoute == candidate || currentRoute.startsWith('$candidate/'),
    );
  }
}
