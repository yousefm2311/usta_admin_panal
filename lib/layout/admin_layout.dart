import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_sizes.dart';
import 'navigation/admin_navigation.dart';
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
    final currentRoute = Get.currentRoute;
    final effectiveTitle = widget.title.trim().isEmpty
        ? AdminNavigation.titleForRoute(currentRoute)
        : widget.title;
    final sectionTitle = AdminNavigation.sectionTitleForRoute(currentRoute);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
        final isMobile = constraints.maxWidth < 600;
        final sidebarCollapsed = isTablet || _collapsed;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: isMobile
              ? Sidebar(collapsed: false, onNavigate: _navigateFromDrawer)
              : null,
          endDrawer: const ControlCenter(),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.background,
                          AppColors.background,
                          AppColors.primary.withOpacity(0.03),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -120,
                  right: -80,
                  child: IgnorePointer(
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.08),
                      ),
                    ),
                  ),
                ),
                Row(
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
                            title: effectiveTitle,
                            sectionTitle: sectionTitle,
                            onMenuTap: isMobile
                                ? () => _scaffoldKey.currentState?.openDrawer()
                                : null,
                            onToggleSidebar: isTablet ? _toggleSidebar : null,
                            onOpenSettings: () =>
                                _scaffoldKey.currentState?.openEndDrawer(),
                            actions: widget.actions,
                          ),
                          Expanded(
                            child: ScrollConfiguration(
                              behavior: const MaterialScrollBehavior().copyWith(
                                scrollbars: true,
                              ),
                              child: SingleChildScrollView(
                                padding: EdgeInsets.fromLTRB(
                                  isDesktop ? AppSizes.lg : AppSizes.md,
                                  AppSizes.md,
                                  isDesktop ? AppSizes.lg : AppSizes.md,
                                  AppSizes.lg,
                                ),
                                child: Center(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 1600,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      child: KeyedSubtree(
                                        key: ValueKey(currentRoute),
                                        child: widget.child,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleSidebar() => setState(() => _collapsed = !_collapsed);

  void _navigateTo(String route) {
    if (Get.currentRoute == route) return;
    Get.offNamed(route);
  }

  void _navigateFromDrawer(String route) {
    _scaffoldKey.currentState?.closeDrawer();
    Future<void>.microtask(() => _navigateTo(route));
  }
}
