import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/profile/controllers/profile_controller.dart';

class TopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenSettings;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    this.onMenuTap,
    this.onToggleSidebar,
    this.onOpenSettings,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final profileController = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);

        return Container(
          height: AppSizes.topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              if (onMenuTap != null)
                IconButton(
                  icon: Icon(Icons.menu, color: AppColors.text),
                  onPressed: onMenuTap,
                ),
              if (onToggleSidebar != null)
                IconButton(
                  icon: Icon(Icons.view_sidebar_outlined, color: AppColors.textMuted),
                  onPressed: onToggleSidebar,
                ),
              Obx(
                () {
                  final data = profileController.profile.value ?? {};
                  final name = (data['name'] ?? 'Admin'.tr).toString();
                  final role = (data['role'] ?? data['kind'] ?? '').toString();
                  final email = (data['email'] ?? '').toString();
                  final avatar = _resolveAvatarUrl(data);
                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.12),
                        backgroundImage: avatar == null ? null : NetworkImage(avatar),
                        child: avatar == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      if (!isCompact) ...[
                        const SizedBox(width: AppSizes.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              role.isNotEmpty ? role.tr : email,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
              if (!isCompact && title.trim().isNotEmpty) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    child: Text(
                      title.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
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
                      if (onOpenSettings != null)
                        IconButton(
                          onPressed: onOpenSettings,
                          icon: Icon(Icons.tune, color: AppColors.textMuted),
                          tooltip: 'Settings'.tr,
                        ),
                      IconButton(
                        onPressed: _logout,
                        icon: Icon(Icons.logout, color: AppColors.textMuted),
                        tooltip: 'Logout'.tr,
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

  Future<void> _logout() async {
    try {
      await Get.find<AuthController>().logout();
    } catch (_) {
      // if not registered, go to login route directly
      Get.offAllNamed('/login');
    }
  }

  String? _resolveAvatarUrl(Map<String, dynamic> data) {
    final candidates = [
      data['avatarUrl'],
      data['avatar'],
      data['photo'],
      data['image'],
      data['profileImage'],
    ];
    for (final value in candidates) {
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
