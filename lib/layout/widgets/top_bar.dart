import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/services/locale_service.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onToggleSidebar;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onToggleSidebar,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return Container(
          height: AppSizes.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: const BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              if (onMenuTap != null)
                IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.text),
                  onPressed: onMenuTap,
                ),
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.text),
              ),
              if (!isCompact) ...[
                const SizedBox(width: AppSizes.sm),
                Text(
                  'Admin'.tr,
                  style: const TextStyle(color: AppColors.text),
                ),
              ],
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.end,
                    children: [
                      if (actions != null) ...actions!,
                      TextButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: AppColors.textMuted, size: 18),
                        label: Text(
                          'Logout'.tr,
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _toggleLocale,
                        icon: const Icon(Icons.language, color: AppColors.textMuted, size: 18),
                        label: Text(
                          Get.locale?.languageCode == 'ar' ? 'English'.tr : 'Arabic'.tr,
                          style: const TextStyle(color: AppColors.text),
                        ),
                      ),
                      if (onToggleSidebar != null)
                        IconButton(
                          icon: const Icon(Icons.view_sidebar_outlined, color: AppColors.textMuted),
                          onPressed: onToggleSidebar,
                        ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title.tr,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'USTA Platform'.tr,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleLocale() {
    final isArabic = Get.locale?.languageCode == 'ar';
    final locale = isArabic ? const Locale('en') : const Locale('ar');
    LocaleService().save(locale);
  }

  Future<void> _logout() async {
    try {
      await Get.find<AuthController>().logout();
    } catch (_) {
      // if not registered, go to login route directly
      Get.offAllNamed('/login');
    }
  }
}
