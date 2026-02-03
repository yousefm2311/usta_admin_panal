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

    return Drawer(
      width: 360,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.tune, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Control Center'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(Icons.close, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: AppColors.text,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Preferences'.tr),
                  Tab(text: 'Account'.tr),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: TabBarView(
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
    return Obx(
      () {
        final isDark = themeController.themeMode.value == ThemeMode.dark;
        final languageLabel =
            Get.locale?.languageCode == 'ar' ? 'Arabic'.tr : 'English'.tr;
        final scalePercent = (themeController.textScale.value * 100).round();

        return GridView(
          padding: const EdgeInsets.all(AppSizes.md),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSizes.md,
            crossAxisSpacing: AppSizes.md,
            childAspectRatio: 1,
          ),
          children: [
            _ControlTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              label: 'Theme'.tr,
              value: isDark ? 'Dark'.tr : 'Light'.tr,
              onTap: themeController.toggleTheme,
            ),
            _ControlTile(
              icon: Icons.language,
              label: 'Language'.tr,
              value: languageLabel,
              onTap: () {
                final isArabic = Get.locale?.languageCode == 'ar';
                final locale = isArabic ? const Locale('en') : const Locale('ar');
                localeService.save(locale);
              },
            ),
            _ControlTile(
              icon: Icons.text_fields,
              label: 'Text size'.tr,
              value: '$scalePercent%',
              onTap: () => _openTextScaleDialog(context, themeController),
            ),
          ],
        );
      },
    );
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
              title: Text('Text size'.tr, style: TextStyle(color: AppColors.text)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Aa',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16 * tempValue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Close'.tr, style: TextStyle(color: AppColors.textMuted)),
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
    return GridView(
      padding: const EdgeInsets.all(AppSizes.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSizes.md,
        crossAxisSpacing: AppSizes.md,
        childAspectRatio: 1,
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
          icon: Icons.logout,
          label: 'Logout'.tr,
          value: '',
          onTap: _logout,
        ),
      ],
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

class _ControlTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ControlTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const Spacer(),
            Text(
              label,
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
            ),
            if (value.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}
