import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../widgets/modules/auth/controllers/auth_controller.dart';
import '../../widgets/modules/profile/controllers/profile_controller.dart';

class TopBar extends StatelessWidget {
  final String title;
  final String sectionTitle;
  final VoidCallback? onMenuTap;
  final VoidCallback? onToggleSidebar;
  final VoidCallback? onOpenSettings;
  final List<Widget>? actions;

  const TopBar({
    super.key,
    required this.title,
    required this.sectionTitle,
    this.onMenuTap,
    this.onToggleSidebar,
    this.onOpenSettings,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 760;
        final showSidebarToggle = onToggleSidebar != null && onMenuTap == null;
        final profileController = Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);

        return Container(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.md,
            AppSizes.md,
            AppSizes.md,
            AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.92),
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onMenuTap != null)
                      _TopBarIconButton(
                        icon: Icons.menu_rounded,
                        tooltip: 'Menu'.tr,
                        onTap: onMenuTap!,
                      ),
                    if (showSidebarToggle)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: _TopBarIconButton(
                          icon: Icons.view_sidebar_outlined,
                          tooltip: 'Sidebar'.tr,
                          onTap: onToggleSidebar!,
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.18),
                                  ),
                                ),
                                child: Text(
                                  sectionTitle.tr,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Text(
                                title.trim().isEmpty ? '' : title.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: isCompact ? 19 : 24,
                                  height: 1.05,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Manage modules, monitor activity, and keep the platform healthy.'
                                .tr,
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
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (actions != null && actions!.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: actions!,
                    ),
                  SizedBox(
                    height: actions != null && actions!.isNotEmpty
                        ? AppSizes.sm
                        : 0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onOpenSettings != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8),
                          child: _TopBarIconButton(
                            icon: Icons.tune_rounded,
                            tooltip: 'Settings'.tr,
                            onTap: onOpenSettings!,
                          ),
                        ),
                      Obx(() {
                        final data =
                            profileController.profile.value ??
                            <String, dynamic>{};
                        final name = (data['name'] ?? 'Admin'.tr).toString();
                        final role = (data['role'] ?? data['kind'] ?? '')
                            .toString();
                        final email = (data['email'] ?? '').toString();
                        final avatar = _resolveAvatarUrl(data);

                        return _ProfileChip(
                          isCompact: isCompact,
                          name: name,
                          roleOrEmail: role.isNotEmpty ? role.tr : email,
                          avatarUrl: avatar,
                          isDark: isDark,
                          onLogout: _logout,
                          onOpenSettings: onOpenSettings,
                        );
                      }),
                    ],
                  ),
                ],
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
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.text),
        ),
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final bool isCompact;
  final String name;
  final String roleOrEmail;
  final String? avatarUrl;
  final bool isDark;
  final VoidCallback onLogout;
  final VoidCallback? onOpenSettings;

  const _ProfileChip({
    required this.isCompact,
    required this.name,
    required this.roleOrEmail,
    required this.avatarUrl,
    required this.isDark,
    required this.onLogout,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border;
    final bg = AppColors.card;

    return PopupMenuButton<String>(
      tooltip: 'Account'.tr,
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: bg,
      onSelected: (v) {
        if (v == 'settings' && onOpenSettings != null) onOpenSettings!();
        if (v == 'logout') onLogout();
      },
      itemBuilder: (_) => [
        PopupMenuItem<String>(
          enabled: false,
          value: 'header',
          child: Row(
            children: [
              _Avatar(name: name, avatarUrl: avatarUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleOrEmail,
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
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (onOpenSettings != null)
          PopupMenuItem<String>(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.tune_rounded, size: 18, color: AppColors.text),
                const SizedBox(width: 10),
                Text(
                  'Settings'.tr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(
                'Logout'.tr,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.14 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(name: name, avatarUrl: avatarUrl),
            if (!isCompact) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      roleOrEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const _Avatar({required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.12),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        image: (avatarUrl == null)
            ? null
            : DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              ),
      ),
      alignment: Alignment.center,
      child: avatarUrl == null
          ? Text(
              initial,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
            )
          : null,
    );
  }
}
