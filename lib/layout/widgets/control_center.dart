import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/theme_controller.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class ControlCenter extends StatelessWidget {
  const ControlCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final localeService = LocaleService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      // Ensure full drawer rebuilds on theme/text scale changes.
      themeController.themeMode.value;
      themeController.textScale.value;

      return Drawer(
        width: 360,
        backgroundColor: AppColors.background,
        child: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // =========================
                // Header
                // =========================
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.md,
                    AppSizes.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(
                            isDark ? 0.18 : 0.12,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
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
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                        ),
                        splashRadius: 22,
                        tooltip: 'Close'.tr,
                      ),
                    ],
                  ),
                ),

                // =========================
                // Tab Bar (Capsule)
                // =========================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.all(5),
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
                          isDark ? 0.18 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.25),
                        ),
                      ),
                      tabs: [
                        Tab(text: 'Preferences'.tr),
                        Tab(text: 'Account'.tr),
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
      );
    });
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
      final scalePercent = (themeController.textScale.value * 100).round();

      return LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final cross = w >= 520 ? 3 : 2; // responsive grid

          return GridView(
            padding: const EdgeInsets.all(AppSizes.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              mainAxisSpacing: AppSizes.md,
              crossAxisSpacing: AppSizes.md,
              childAspectRatio: 1.05,
            ),
            children: [
              _ControlTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: 'Theme'.tr,
                value: isDark ? 'Dark'.tr : 'Light'.tr,
                onTap: themeController.toggleTheme,
              ),
              _ControlTile(
                icon: Icons.language_rounded,
                label: 'Language'.tr,
                value: languageLabel,
                onTap: () {
                  final isArabic = Get.locale?.languageCode == 'ar';
                  final locale = isArabic
                      ? const Locale('en')
                      : const Locale('ar');
                  localeService.save(locale);
                },
              ),
              _ControlTile(
                icon: Icons.text_fields_rounded,
                label: 'Text size'.tr,
                value: '$scalePercent%',
                onTap: () => _openTextScaleDialog(context, themeController),
              ),
            ],
          );
        },
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
                    onChangeEnd: controller.setTextScale,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    controller.setTextScale(1.0);
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
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cross = w >= 520 ? 3 : 2;

        return GridView(
          padding: const EdgeInsets.all(AppSizes.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1.05,
          ),
          children: [
            _ControlTile(
              icon: Icons.settings_outlined,
              label: 'Settings'.tr,
              value: 'General'.tr,
              onTap: () => Get.offAllNamed('/settings'),
            ),
            _ControlTile(
              icon: Icons.account_circle_outlined,
              label: 'Profile'.tr,
              value: 'Account'.tr,
              onTap: () => Get.offAllNamed('/profile'),
            ),
            _ControlTile(
              icon: Icons.logout_rounded,
              label: 'Logout'.tr,
              value: '',
              danger: true,
              onTap: _logout,
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    try {
      await Get.find<AuthController>().logout();
    } catch (_) {
      Get.offAllNamed('/login');
    }
  }
}

class _ControlTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool danger;

  const _ControlTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.danger = false,
  });

  @override
  State<_ControlTile> createState() => _ControlTileState();
}

class _ControlTileState extends State<_ControlTile> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = widget.danger ? const Color(0xFFDC2626) : AppColors.primary;
    final accentBg = accent.withOpacity(isDark ? 0.18 : 0.12);

    final scale = _down ? 0.98 : 1.0;
    final lift = _hover ? -2.0 : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, lift)
            ..scale(scale),
          padding: const EdgeInsets.all(AppSizes.sm),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              if (_hover)
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.22 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // icon
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withOpacity(0.25)),
                ),
                child: Icon(widget.icon, color: accent),
              ),

              const Spacer(),

              Text(
                widget.label,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              if (widget.value.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
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
                      widget.value,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
