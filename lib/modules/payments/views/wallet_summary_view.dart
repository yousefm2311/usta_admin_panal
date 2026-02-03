import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/payouts_controller.dart';

class WalletSummaryView extends StatefulWidget {
  const WalletSummaryView({super.key});

  @override
  State<WalletSummaryView> createState() => _WalletSummaryViewState();
}

class _WalletSummaryViewState extends State<WalletSummaryView> {
  late final PayoutsController controller;
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PayoutsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;
    controller.loadWallets();
    loadedOnce = true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color success() => const Color(0xFF16A34A);

    return AdminLayout(
      title: 'Wallet Summary'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 220, lines: 6);
        }

        if (controller.error.value != null) {
          return _StateBox(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong'.tr,
            subtitle: controller.error.value!,
            onRetry: controller.loadWallets,
          );
        }

        if (controller.wallets.isEmpty) {
          return _StateBox(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No data'.tr,
            subtitle: 'No wallets found'.tr,
            onRetry: controller.loadWallets,
          );
        }

        // wallets might be RxList<dynamic> في بعض المشاريع
        final wallets = controller.wallets
            .map((e) => e)
            .toList(growable: false);

        final stats = _calcStats(wallets);
        final count = wallets.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // Header
            // =========================
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Summary'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Wallets'.tr}: $count',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _ActionButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh'.tr,
                  onTap: controller.loadWallets,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // KPIs
            // =========================
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: [
                _KpiCard(
                  title: 'Total balance'.tr,
                  value: _money(stats.total),
                  icon: Icons.payments_outlined,
                  valueColor: success(),
                ),
                _KpiCard(
                  title: 'Average'.tr,
                  value: _money(stats.avg),
                  icon: Icons.stacked_line_chart_rounded,
                  valueColor: AppColors.text,
                ),
                _KpiCard(
                  title: 'Max wallet'.tr,
                  value: _money(stats.max),
                  icon: Icons.trending_up_rounded,
                  valueColor: AppColors.text,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // List Card
            // =========================
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Wallet balances'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${'Total'.tr}: ${_money(stats.total)}',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // separator
                  Container(
                    height: 1,
                    color: AppColors.border.withOpacity(0.8),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  ...List.generate(wallets.length, (i) {
                    final w = wallets[i];
                    final name = _ownerName(w);
                    final balanceNum = _balanceValue(w);
                    final subtitle = _ownerSub(w);

                    final zebra = i.isEven
                        ? (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC))
                        : AppColors.card;

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: zebra,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.border.withOpacity(0.7),
                        ),
                      ),
                      child: Row(
                        children: [
                          _AvatarLetter(text: name),
                          const SizedBox(width: AppSizes.md),
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
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.md),
                          Text(
                            _money(balanceNum),
                            style: TextStyle(
                              color: balanceNum >= 0
                                  ? success()
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // Helpers
  // =========================

_WalletStats _calcStats(List<Map<String, dynamic>> wallets) {
    double total = 0;
    double max = 0;

    for (final w in wallets) {
      final v = _balanceValue(w);
      total += v;
      if (v > max) max = v;
    }

    final double avg = wallets.isEmpty ? 0.0 : total / wallets.length;

    return _WalletStats(total: total, avg: avg, max: max);
  }

  double _balanceValue(Map<String, dynamic> w) {
    final raw = w['balance'] ?? w['amount'] ?? 0;
    return double.tryParse(raw.toString()) ?? 0;
  }

  String _money(double v) => 'EG ${v.toStringAsFixed(2)}';

  String _ownerSub(Map<String, dynamic> wallet) {
    // subtitle لطيف تحت الاسم (email/phone/ownerId لو موجود)
    final user = wallet['user'];
    if (user is Map<String, dynamic>) {
      final email = user['email'];
      final phone = user['phone'];
      final sub = email ?? phone;
      if (sub != null && sub.toString().trim().isNotEmpty)
        return sub.toString();
    }
    final email = wallet['email'];
    final phone = wallet['phone'];
    final sub = email ?? phone ?? wallet['_id'] ?? '';
    return sub.toString().isEmpty ? '—' : sub.toString();
  }

  String _ownerName(Map<String, dynamic> wallet) {
    final owner = wallet['owner'];
    if (owner is String && owner.trim().isNotEmpty) return owner;

    final user = wallet['user'];
    if (user is Map<String, dynamic>) {
      final name =
          user['name'] ?? user['fullName'] ?? user['email'] ?? user['phone'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString();
      }
    }

    final name = wallet['name'] ?? wallet['email'] ?? wallet['phone'];
    if (name != null && name.toString().trim().isNotEmpty) {
      return name.toString();
    }

    return '-';
  }
}

// =========================
// UI bits
// =========================

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          color: AppColors.card,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.text),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color valueColor;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  final String text;
  const _AvatarLetter({required this.text});

  @override
  Widget build(BuildContext context) {
    final letter = text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase();
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        letter,
        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _StateBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _StateBox({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSizes.md),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text('Retry'.tr),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletStats {
  final double total;
  final double avg;
  final double max;
  _WalletStats({required this.total, required this.avg, required this.max});
}
