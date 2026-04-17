import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/profile_controller.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 7);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final data = controller.profile.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final name = (data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? '').toString().trim();
        final role = (data['role'] ?? data['kind'] ?? '').toString().trim();

        final settings = (data['settings'] is Map)
            ? Map<String, dynamic>.from(data['settings'] as Map)
            : <String, dynamic>{};

        final language = (settings['language'] ?? '').toString().trim();
        final theme = (settings['theme'] ?? '').toString().trim();
        final createdAt = (data['createdAt'] ?? '').toString().trim();
        final currentTheme = theme.isEmpty ? '-' : theme.tr;
        final currentLanguage = language.isEmpty ? '-' : language.tr;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              title: 'Profile',
              subtitle:
                  'See account identity, system preferences, and quick security actions for the current admin.',
              badges: [
                AdminInfoBadge(
                  icon: Icons.badge_outlined,
                  label: 'Profile overview',
                ),
                AdminInfoBadge(
                  icon: Icons.security_outlined,
                  label: 'Secure account',
                  color: Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth >= 1100
                    ? (constraints.maxWidth - AppSizes.md * 2) / 3
                    : constraints.maxWidth >= 720
                    ? (constraints.maxWidth - AppSizes.md) / 2
                    : constraints.maxWidth;
                return Wrap(
                  spacing: AppSizes.md,
                  runSpacing: AppSizes.md,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Status overview',
                        value: role.isEmpty ? 'Admin'.tr : role.tr,
                        subtitle: 'Role access',
                        icon: Icons.admin_panel_settings_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Language',
                        value: currentLanguage,
                        subtitle: 'Preferences',
                        icon: Icons.language_rounded,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Theme',
                        value: currentTheme,
                        subtitle: 'Secure account',
                        icon: Icons.dark_mode_outlined,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.md),
            _headerCard(
              context,
              name: name,
              email: email,
              role: role,
              // اختياري: اربطهم بعدين لو عندك APIs
              onChangePassword: null,
              onLogout: null,
            ),
            const SizedBox(height: AppSizes.md),

            if (isMobile)
              Column(
                children: [
                  _accountCard(email: email, role: role, createdAt: createdAt),
                  const SizedBox(height: AppSizes.md),
                  _preferencesCard(language: language, theme: theme),
                  const SizedBox(height: AppSizes.md),
                  _securityCard(email: email),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _accountCard(
                      email: email,
                      role: role,
                      createdAt: createdAt,
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      children: [
                        _preferencesCard(language: language, theme: theme),
                        const SizedBox(height: AppSizes.md),
                        _securityCard(email: email),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }

  // =========================
  // Header
  // =========================

  Widget _headerCard(
    BuildContext context, {
    required String name,
    required String email,
    required String role,
    VoidCallback? onChangePassword,
    VoidCallback? onLogout,
  }) {
    final initials = _initials(name);
    final roleColor = _roleColor(role);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.25)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Admin'.tr : name,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? '-' : email,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                if (role.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: roleColor.withOpacity(0.35)),
                    ),
                    child: Text(
                      role.tr,
                      style: TextStyle(
                        color: roleColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Actions (اختيارية)
          Row(
            children: [
              if (onChangePassword != null)
                TextButton.icon(
                  onPressed: onChangePassword,
                  icon: Icon(Icons.lock_reset, color: AppColors.primary),
                  label: Text(
                    'Change password'.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (onLogout != null) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: Text(
                    'Logout'.tr,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // =========================
  // Cards
  // =========================

  Widget _accountCard({
    required String email,
    required String role,
    required String createdAt,
  }) {
    return _card(
      title: 'Account info'.tr,
      icon: Icons.account_circle_outlined,
      child: Column(
        children: [
          _kvRow('Email'.tr, email),
          _divider(),
          _kvRow('Role'.tr, role.isEmpty ? '-' : role.tr),
          if (createdAt.isNotEmpty) ...[
            _divider(),
            _kvRow('Created at'.tr, createdAt),
          ],
        ],
      ),
    );
  }

  Widget _preferencesCard({required String language, required String theme}) {
    return _card(
      title: 'Preferences'.tr,
      icon: Icons.tune,
      child: Column(
        children: [
          _kvRow('Language'.tr, language.isEmpty ? '-' : language.tr),
          _divider(),
          _kvRow('Theme'.tr, theme.isEmpty ? '-' : theme.tr),
        ],
      ),
    );
  }

  Widget _securityCard({required String email}) {
    return _card(
      title: 'Security'.tr,
      icon: Icons.security_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick actions'.tr,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionChip(
                icon: Icons.copy,
                label: 'Copy email'.tr,
                enabled: email.isNotEmpty,
                onTap: email.isEmpty
                    ? null
                    : () async {
                        await Clipboard.setData(ClipboardData(text: email));
                        // لو عندك notify helper استخدمه، هنا مش هنستورد حاجة زيادة
                        Get.snackbar(
                          'Done'.tr,
                          'Copied'.tr,
                          backgroundColor: AppColors.overlay,
                          colorText: AppColors.text,
                        );
                      },
              ),
              _actionChip(
                icon: Icons.lock_reset,
                label: 'Change password'.tr,
                enabled: false, // اربطها لما تعمل API
                onTap: null,
              ),
              _actionChip(
                icon: Icons.logout,
                label: 'Logout'.tr,
                enabled: false, // اربطها لما تعمل logout logic
                onTap: null,
                danger: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return AdminSectionCard(title: title, icon: icon, child: child);
  }

  Widget _kvRow(String k, String v) {
    return Row(
      children: [
        Text(
          k,
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            v.isEmpty ? '-' : v,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.border.withOpacity(0.7)),
  );

  Widget _actionChip({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback? onTap,
    bool danger = false,
  }) {
    final baseColor = danger ? Colors.redAccent : AppColors.primary;
    final bg = enabled ? baseColor.withOpacity(0.12) : AppColors.overlay;
    final br = enabled
        ? baseColor.withOpacity(0.35)
        : AppColors.border.withOpacity(0.7);
    final tx = enabled ? baseColor : AppColors.textMuted;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: br),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: tx),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: tx,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // Utils
  // =========================

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Color _roleColor(String role) {
    final r = role.trim().toLowerCase();
    if (r.contains('super') || r.contains('owner')) return Colors.purpleAccent;
    if (r.contains('admin')) return AppColors.primary;
    if (r.contains('manager')) return Colors.tealAccent;
    return AppColors.textMuted;
  }
}
