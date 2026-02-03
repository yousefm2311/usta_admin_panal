import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'widgets/control_center.dart';
import 'widgets/sidebar.dart';
import 'widgets/top_bar.dart';

class AdminLayout extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AdminLayout({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final isMobile = constraints.maxWidth < 600;
        final sidebarCollapsed = isTablet || _collapsed;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isMobile
              ? Sidebar(
                  collapsed: false,
                  onNavigate: _navigateFromDrawer,
                )
              : null,
          endDrawer: const ControlCenter(),
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMobile)
                  Sidebar(
                    collapsed: sidebarCollapsed,
                    onNavigate: _navigateTo,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      TopBar(
                        title: widget.title,
                        onMenuTap: isMobile ? () => _scaffoldKey.currentState?.openDrawer() : null,
                        onToggleSidebar: isDesktop ? null : _toggleSidebar,
                        onOpenSettings: () => _scaffoldKey.currentState?.openEndDrawer(),
                        actions: widget.actions,
                      ),
                      const SizedBox(height: AppSizes.md),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? AppSizes.md : AppSizes.sm,
                            vertical: AppSizes.sm,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1600),
                              child: widget.child,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSidebar() => setState(() => _collapsed = !_collapsed);

  void _navigateTo(String route) => Get.offAllNamed(route);

  void _navigateFromDrawer(String route) {
    _navigateTo(route);
    _scaffoldKey.currentState?.closeDrawer();
  }
}
