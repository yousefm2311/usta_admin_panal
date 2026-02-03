import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/payments_controller.dart';
import '../../../widgets/shimmer_widgets.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color surface() => isDark ? const Color(0xFF121826) : Colors.white;
    Color border() =>
        isDark ? const Color(0xFF233044) : const Color(0xFFE6E8EF);

    // بدائل لو AppColors ما فيهاش success/danger
    Color success() => const Color(0xFF16A34A);
    Color danger() => const Color(0xFFDC2626);
    Color warn() => const Color(0xFFF59E0B);

    return AdminLayout(
      title: 'Transactions'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading();
        }

        if (controller.error.value != null) {
          return _StateBox(
            icon: Icons.error_outline_rounded,
            title: 'Something went wrong'.tr,
            subtitle: controller.error.value!,
            onRetry: () {
              // لو عندك load/refresh function في controller استخدمها
              // controller.load();
            },
          );
        }

        if (controller.transactions.isEmpty) {
          return _StateBox(
            icon: Icons.inbox_outlined,
            title: 'No data'.tr,
            subtitle: 'No transactions yet'.tr,
          );
        }

        final stats = _calcStats(controller.transactions);
        final totalCount = controller.transactions.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // Header
            // =========================
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'Total'.tr}: $totalCount',
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
                  onTap: () {
                    // لو عندك refresh
                    // controller.load();
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // Stats
            // =========================
            Wrap(
              spacing: AppSizes.md,
              runSpacing: AppSizes.md,
              children: [
                _StatCard(
                  title: 'Net'.tr,
                  value: 'EG ${stats.net.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet_outlined,
                  valueColor: stats.net >= 0 ? success() : danger(),
                ),
                _StatCard(
                  title: 'Credit'.tr,
                  value: 'EG ${stats.credit.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                  valueColor: success(),
                ),
                _StatCard(
                  title: 'Debit'.tr,
                  value: 'EG ${stats.debit.toStringAsFixed(2)}',
                  icon: Icons.trending_down_rounded,
                  valueColor: danger(),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // Table
            // =========================
            Container(
              decoration: BoxDecoration(
                color: surface(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border()),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.20 : 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSizes.md),
              child: TableWrapper(
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowHeight: 44,
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  dividerThickness: 0.7,
                  columnSpacing: 18,
                  horizontalMargin: 12,

                  // Zebra rows
                  dataRowColor: WidgetStateProperty.resolveWith<Color?>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary.withOpacity(0.12);
                    }
                    // مفيش index هنا، فهنعمل zebra بإضافة Container لكل Cell (أسهل)
                    return null;
                  }),

                  columns: [
                    DataColumn(label: _Head('Customer'.tr)),
                    DataColumn(label: _Head('Amount'.tr)),
                    DataColumn(label: _Head('Method'.tr)),
                    DataColumn(label: _Head('Date'.tr)),
                    DataColumn(label: _Head('Status'.tr)),
                  ],
                  rows: List.generate(controller.transactions.length, (i) {
                    final p = controller.transactions[i];
                    final amount = _formatAmountValue(p);
                    final isPositive = amount >= 0;

                    final status = (p['status'] ?? '').toString();
                    final statusUi = _statusChip(
                      status,
                      success: success(),
                      danger: danger(),
                      warn: warn(),
                      muted: AppColors.textMuted,
                      isDark: isDark,
                    );

                    // Zebra background per row (حل عملي مع DataTable)
                    final zebra = i.isEven
                        ? (isDark
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC))
                        : surface();

                    return DataRow(
                      onSelectChanged: (_) {
                        // لو تحب تفتح تفاصيل العملية
                      },
                      cells: [
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Text(
                              (p['customerName'] ?? p['customerId'] ?? '')
                                  .toString(),
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Text(
                              _formatAmountText(amount),
                              style: TextStyle(
                                color: isPositive ? success() : danger(),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Text(
                              (p['method'] ?? p['paymentMethod'] ?? '')
                                  .toString(),
                              style: TextStyle(color: AppColors.text),
                            ),
                          ),
                        ),
                        DataCell(
                          _ZebraCell(
                            zebra: zebra,
                            child: Text(
                              _formatDate(p['date'] ?? p['createdAt']),
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(_ZebraCell(zebra: zebra, child: statusUi)),
                      ],
                    );
                  }),
                  headingTextStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                  dataTextStyle: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
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

  _TxStats _calcStats(List<Map<String, dynamic>> txs) {
    double credit = 0;
    double debit = 0;

    for (final p in txs) {
      final c =
          double.tryParse((p['credit'] ?? p['amount'] ?? 0).toString()) ?? 0;
      final d = double.tryParse((p['debit'] ?? 0).toString()) ?? 0;
      if (c > 0) credit += c;
      if (d > 0) debit += d;
    }

    return _TxStats(credit: credit, debit: debit, net: credit - debit);
  }

  double _formatAmountValue(Map<String, dynamic> p) {
    final credit =
        double.tryParse((p['credit'] ?? p['amount'] ?? 0).toString()) ?? 0;
    final debit = double.tryParse((p['debit'] ?? 0).toString()) ?? 0;
    if (credit > 0) return credit;
    if (debit > 0) return -debit;
    return 0;
  }

  String _formatAmountText(double value) {
    final prefix = value >= 0 ? '+' : '';
    return 'EG $prefix${value.toStringAsFixed(2)}';
  }

  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  Widget _statusChip(
    String status, {
    required Color success,
    required Color danger,
    required Color warn,
    required Color muted,
    required bool isDark,
  }) {
    final s = status.trim().toLowerCase();

    Color bg;
    Color fg;
    String label = status.isEmpty ? '—' : status;

    if (s.contains('paid') || s.contains('success') || s.contains('done')) {
      bg = success.withOpacity(isDark ? 0.18 : 0.12);
      fg = success;
    } else if (s.contains('pending') || s.contains('process')) {
      bg = warn.withOpacity(isDark ? 0.18 : 0.12);
      fg = warn;
    } else if (s.contains('fail') ||
        s.contains('cancel') ||
        s.contains('reject')) {
      bg = danger.withOpacity(isDark ? 0.18 : 0.12);
      fg = danger;
    } else {
      bg = muted.withOpacity(isDark ? 0.18 : 0.10);
      fg = muted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

// =========================
// Small UI widgets
// =========================

class _Head extends StatelessWidget {
  final String text;
  const _Head(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

class _ZebraCell extends StatelessWidget {
  final Color zebra;
  final Widget child;
  const _ZebraCell({required this.zebra, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: zebra,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: child,
    );
  }
}

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
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color valueColor;

  const _StatCard({
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
                    fontWeight: FontWeight.w800,
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
                    fontWeight: FontWeight.w800,
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

class _TxStats {
  final double credit;
  final double debit;
  final double net;
  _TxStats({required this.credit, required this.debit, required this.net});
}
