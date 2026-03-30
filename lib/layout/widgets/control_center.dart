import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/theme_controller.dart';
import '../../widgets/modules/auth/controllers/auth_controller.dart';

class ControlCenter extends StatelessWidget {
  const ControlCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeService = LocaleService();

    return Obx(() {
      themeController.themeMode.value;
      themeController.textScale.value;

      final isDark = Theme.of(context).brightness == Brightness.dark;
      final languageLabel = Get.locale?.languageCode == 'ar'
          ? 'Arabic'.tr
          : 'English'.tr;
      final themeLabel = themeController.themeMode.value == ThemeMode.dark
          ? 'Dark'.tr
          : 'Light'.tr;
      final textScaleLabel =
          '${(themeController.textScale.value * 100).round()}%';
      final screenWidth = MediaQuery.sizeOf(context).width;
      final preferredDrawerWidth = screenWidth * 0.92;
      final drawerWidth = math.max(
        0.0,
        math.min(380.0, math.min(preferredDrawerWidth, screenWidth - 8)),
      );

      return Drawer(
        width: drawerWidth,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: SafeArea(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.26 : 0.08),
                  blurRadius: 26,
                  offset: const Offset(-10, 0),
                ),
              ],
              border: Border(
                left: BorderSide(color: AppColors.border.withOpacity(0.9)),
              ),
            ),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.md,
                      AppSizes.sm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(
                            isDark ? 0.35 : 0.25,
                          ),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(isDark ? 0.22 : 0.12),
                            AppColors.card,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(
                                    isDark ? 0.2 : 0.16,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Control Center'.tr,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Quick preferences & account'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    Navigator.of(context).maybePop(),
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: AppColors.textMuted,
                                ),
                                splashRadius: 22,
                                tooltip: 'Close'.tr,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _HeaderBadge(
                                icon: Icons.dark_mode_rounded,
                                label: 'Theme'.tr,
                                value: themeLabel,
                                accent: AppColors.primary,
                              ),
                              _HeaderBadge(
                                icon: Icons.language_rounded,
                                label: 'Language'.tr,
                                value: languageLabel,
                                accent: AppColors.success,
                              ),
                              _HeaderBadge(
                                icon: Icons.text_fields_rounded,
                                label: 'Text size'.tr,
                                value: textScaleLabel,
                                accent: AppColors.warning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: Container(
                      height: 46,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelPadding: EdgeInsets.zero,
                        labelColor: AppColors.text,
                        unselectedLabelColor: AppColors.textMuted,
                        indicator: BoxDecoration(
                          color: AppColors.primary.withOpacity(
                            isDark ? 0.2 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.tune_rounded, size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Preferences'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.manage_accounts_outlined,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Account'.tr,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Expanded(
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _PreferencesTab(
                          themeController: themeController,
                          localeService: localeService,
                        ),
                        const _AccountTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _HeaderBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _HeaderBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 420;
    final badgeWidth = isCompact ? 148.0 : 168.0;

    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(isDark ? 0.7 : 0.96),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.2 : 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 13, color: accent),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesTab extends StatelessWidget {
  final ThemeController themeController;
  final LocaleService localeService;

  const _PreferencesTab({
    required this.themeController,
    required this.localeService,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final languageLabel = Get.locale?.languageCode == 'ar'
          ? 'Arabic'.tr
          : 'English'.tr;
      final scalePercent =
          '${(themeController.textScale.value * 100).round()}%';

      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.md,
          AppSizes.xs,
          AppSizes.md,
          AppSizes.md,
        ),
        children: [
          _SectionCard(
            title: 'Appearance'.tr,
            subtitle: 'Theme and readability'.tr,
            children: [
              _ActionRow(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: 'Theme'.tr,
                subtitle: 'Switch light / dark mode'.tr,
                value: isDark ? 'Dark'.tr : 'Light'.tr,
                onTap: themeController.toggleTheme,
              ),
              _ActionRow(
                icon: Icons.text_fields_rounded,
                title: 'Text size'.tr,
                subtitle: 'Adjust interface scaling'.tr,
                value: scalePercent,
                onTap: () => _openTextScaleDialog(context, themeController),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          _SectionCard(
            title: 'Localization'.tr,
            subtitle: 'Language preferences'.tr,
            children: [
              _ActionRow(
                icon: Icons.language_rounded,
                title: 'Language'.tr,
                subtitle: 'Switch Arabic / English'.tr,
                value: languageLabel,
                onTap: () {
                  final isArabic = Get.locale?.languageCode == 'ar';
                  final locale = isArabic
                      ? const Locale('en')
                      : const Locale('ar');
                  localeService.save(locale);
                },
              ),
            ],
          ),
        ],
      );
    });
  }

  void _openTextScaleDialog(BuildContext context, ThemeController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        var tempValue = controller.textScale.value;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                'Text size'.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview'.tr,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aa'.tr,
                          style: TextStyle(
                            color: AppColors.text,
                            fontSize: 16 * tempValue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Slider(
                    value: tempValue,
                    min: 0.85,
                    max: 1.35,
                    divisions: 5,
                    label: '${(tempValue * 100).round()}%',
                    onChanged: (value) => setState(() => tempValue = value),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => tempValue = 1.0);
                    controller.setTextScale(tempValue);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Reset'.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Close'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    controller.setTextScale(tempValue);
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Apply'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        AppSizes.xs,
        AppSizes.md,
        AppSizes.md,
      ),
      children: [
        _SectionCard(
          title: 'Workspace'.tr,
          subtitle: 'Open admin areas quickly'.tr,
          children: [
            _ActionRow(
              icon: Icons.settings_outlined,
              title: 'Settings'.tr,
              subtitle: 'Manage system preferences'.tr,
              value: 'General'.tr,
              onTap: () => _navigateFromDrawer(context, '/settings'),
            ),
            _ActionRow(
              icon: Icons.account_circle_outlined,
              title: 'Profile'.tr,
              subtitle: 'View account information'.tr,
              value: 'Account'.tr,
              onTap: () => _navigateFromDrawer(context, '/profile'),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        _SectionCard(
          title: 'Session'.tr,
          subtitle: 'Security and access'.tr,
          children: [
            _ActionRow(
              icon: Icons.logout_rounded,
              title: 'Logout'.tr,
              subtitle: 'Sign out from this device'.tr,
              danger: true,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateFromDrawer(BuildContext context, String route) {
    Navigator.of(context).maybePop();
    Future<void>.microtask(() => Get.offAllNamed(route));
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).maybePop();
    try {
      await Get.find<AuthController>().logout();
    } catch (_) {
      Get.offAllNamed('/login');
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withOpacity(0.8)),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(height: 1, color: AppColors.border.withOpacity(0.65)),
          ],
        ],
      ),
    );
  }
}

class _ActionRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final VoidCallback onTap;
  final bool danger;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<_ActionRow> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.danger ? AppColors.danger : AppColors.primary;
    final hasValue = widget.value != null && widget.value!.trim().isNotEmpty;

    final scale = _down ? 0.99 : 1.0;
    final bg = _hover
        ? AppColors.overlay.withOpacity(isDark ? 0.35 : 0.95)
        : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(scale),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hover ? accent.withOpacity(0.25) : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _down = true),
            onTapCancel: () => setState(() => _down = false),
            onTapUp: (_) => setState(() => _down = false),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(isDark ? 0.22 : 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: accent.withOpacity(0.28)),
                    ),
                    child: Icon(widget.icon, color: accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.danger ? accent : AppColors.text,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasValue) ...[
                    const SizedBox(width: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.9),
                          ),
                        ),
                        child: Text(
                          widget.value!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 2),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
