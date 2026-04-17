import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_content_widgets.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/payments_controller.dart';

class PaymentsListView extends StatelessWidget {
  const PaymentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PaymentsController());

    return AdminLayout(
      title: '',
      child: Obx(() {
        final totalTransactions = controller.transactions.length;
        final pendingTransactions = controller.transactions.where((payment) {
          final status = (payment['status'] ?? '').toString().toLowerCase();
          return status == 'pending' || status == 'new';
        }).length;
        final totalAmount = controller.transactions.fold<double>(
          0,
          (sum, payment) =>
              sum +
              (double.tryParse(
                    (payment['finalAmount'] ?? payment['amount'] ?? 0)
                        .toString(),
                  ) ??
                  0),
        );
        final Widget body;

        if (controller.loading.value) {
          body = const CardLoading(lines: 10);
        } else if (controller.error.value != null) {
          body = Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              controller.error.value!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        } else if (controller.transactions.isEmpty) {
          body = Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        } else {
          body = TableWrapper(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Customer'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Method'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Actions'.tr)),
                ],
                rows: controller.transactions.map((raw) {
                  final p = raw as Map<String, dynamic>? ?? <String, dynamic>{};

                  final customerName = controller.userNameFor(p);
                  final amount = p['finalAmount'] ?? p['amount'] ?? 0;
                  final method = _resolveMethod(p);
                  final date = p['date'] ?? p['createdAt'];
                  final status = (p['status'] ?? '').toString();

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          customerName.isEmpty ? '—' : customerName,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(_amountText(amount)),
                      DataCell(_methodChip(method)),
                      DataCell(Text(_formatDate(date))),
                      DataCell(_statusChip(status)),
                      DataCell(
                        TextButton(
                          onPressed: () =>
                              Get.toNamed('/payment/details', arguments: p),
                          child: Text('View details'.tr),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                headingTextStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
                dataTextStyle: TextStyle(color: AppColors.text),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminPageHeader(
              title: 'Payments',
              subtitle:
                  'Track transactions and settlements with a cleaner overview for finance operations.',
              actions: [
                OutlinedButton.icon(
                  onPressed: () => _openFilterDialog(context, controller),
                  icon: const Icon(Icons.filter_list_rounded, size: 18),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Filter'.tr),
                      if (controller.filter.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _miniBadge(controller.filter.length.toString()),
                      ],
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: controller.filter.isEmpty
                      ? null
                      : controller.clearFilter,
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  label: Text('Clear'.tr),
                ),
                IconButton(
                  onPressed: controller.loadTransactions,
                  icon: Icon(Icons.refresh_rounded, color: AppColors.textMuted),
                  tooltip: 'Refresh'.tr,
                ),
              ],
              badges: [
                AdminInfoBadge(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Payments hub',
                ),
                AdminInfoBadge(
                  icon: Icons.query_stats_outlined,
                  label: controller.filter.isEmpty
                      ? 'Settlement health'
                      : '${'Filters'.tr}: ${controller.filter.length}',
                  color: Colors.teal,
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
                        label: 'Transaction volume',
                        value: totalTransactions.toString(),
                        subtitle: 'Payments volume',
                        icon: Icons.receipt_long_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Total revenue',
                        value: 'EGP ${totalAmount.toStringAsFixed(0)}',
                        subtitle: 'Settlement health',
                        icon: Icons.payments_outlined,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: AdminStatTile(
                        label: 'Need review',
                        value: pendingTransactions.toString(),
                        subtitle: 'Pending and new payments',
                        icon: Icons.flag_outlined,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSizes.md),
            body,
          ],
        );
      }),
    );
  }

  // =========================
  // UI HELPERS
  // =========================
  static Widget _miniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();
    Color c = AppColors.textMuted;

    if (s == 'paid' || s == 'success' || s == 'completed' || s == 'done') {
      c = AppColors.success;
    } else if (s == 'pending' || s == 'new') {
      c = AppColors.warning;
    } else if (s == 'failed' ||
        s == 'cancelled' ||
        s == 'canceled' ||
        s == 'rejected') {
      c = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Text(
        (status.isEmpty ? '—' : status).tr,
        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }

  Widget _methodChip(String method) {
    final m = method.toLowerCase().trim();
    final isCash = m.contains('cash');
    final isCard =
        m.contains('card') || m.contains('visa') || m.contains('master');
    final isWallet =
        m.contains('wallet') || m.contains('vodafone') || m.contains('fawry');

    final c = isCash
        ? Colors.blueGrey
        : isCard
        ? AppColors.primary
        : isWallet
        ? Colors.teal
        : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withOpacity(0.35)),
      ),
      child: Text(
        (method.isEmpty ? '—' : method).tr,
        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }

  Widget _amountText(dynamic value) {
    final n = double.tryParse(value.toString()) ?? 0;
    final c = n >= 0 ? AppColors.text : Colors.redAccent;

    String txt;
    final abs = n.abs();

    if (abs >= 1000000) {
      txt = '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      txt = '${(n / 1000).toStringAsFixed(1)}K';
    } else {
      txt = n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(2);
    }

    return Text(
      'EGP $txt',
      style: TextStyle(color: c, fontWeight: FontWeight.w900),
    );
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

  String _resolveMethod(Map<String, dynamic> payment) {
    final direct = _stringFrom(
      payment['method'] ??
          payment['paymentMethod'] ??
          payment['payment_method'] ??
          payment['methodName'] ??
          payment['methodType'] ??
          payment['type'] ??
          payment['channel'] ??
          payment['gateway'] ??
          payment['provider'] ??
          payment['source'],
    );
    if (direct.isNotEmpty) return direct;

    return _stringFrom(
      payment['payment'] ??
          payment['details'] ??
          payment['meta'] ??
          payment['data'],
      keys: const [
        'method',
        'paymentMethod',
        'payment_method',
        'methodName',
        'methodType',
        'type',
        'channel',
        'gateway',
        'provider',
        'source',
      ],
    );
  }

  String _stringFrom(
    dynamic value, {
    List<String> keys = const [
      'name',
      'fullName',
      'displayName',
      'username',
      'email',
      'phone',
      'title',
      'label',
      'type',
      'method',
      'paymentMethod',
      'payment_method',
      'methodName',
      'methodType',
      'channel',
      'gateway',
      'provider',
      'source',
    ],
  }) {
    if (value == null) return '';
    if (value is String || value is num) return value.toString();
    if (value is Map<String, dynamic>) {
      for (final key in keys) {
        final raw = value[key];
        if (raw == null) continue;
        final text = raw.toString();
        if (text.trim().isNotEmpty) return text;
      }
    }
    return '';
  }

  // =========================
  // FILTER DIALOG
  // =========================
  void _openFilterDialog(BuildContext context, PaymentsController controller) {
    final statusCtrl = TextEditingController(
      text: controller.filter['status']?.toString() ?? '',
    );
    final methodCtrl = TextEditingController(
      text: controller.filter['method']?.toString() ?? '',
    );
    final customerCtrl = TextEditingController(
      text: controller.filter['customerId']?.toString() ?? '',
    );
    final artisanCtrl = TextEditingController(
      text: controller.filter['artisanId']?.toString() ?? '',
    );
    final fromCtrl = TextEditingController(
      text: controller.filter['from']?.toString() ?? '',
    );
    final toCtrl = TextEditingController(
      text: controller.filter['to']?.toString() ?? '',
    );
    final minCtrl = TextEditingController(
      text: controller.filter['min']?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: controller.filter['max']?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Filters'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _filterField(statusCtrl, 'Status'.tr),
              _filterField(methodCtrl, 'Method'.tr),
              _filterField(customerCtrl, 'Customer ID'.tr),
              _filterField(artisanCtrl, 'Artisan ID'.tr),
              _filterField(fromCtrl, 'From (ISO date)'.tr),
              _filterField(toCtrl, 'To (ISO date)'.tr),
              _filterField(
                minCtrl,
                'Min amount'.tr,
                keyboard: TextInputType.number,
              ),
              _filterField(
                maxCtrl,
                'Max amount'.tr,
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();

              final params = <String, dynamic>{};
              if (statusCtrl.text.trim().isNotEmpty)
                params['status'] = statusCtrl.text.trim();
              if (methodCtrl.text.trim().isNotEmpty)
                params['method'] = methodCtrl.text.trim();
              if (customerCtrl.text.trim().isNotEmpty)
                params['customerId'] = customerCtrl.text.trim();
              if (artisanCtrl.text.trim().isNotEmpty)
                params['artisanId'] = artisanCtrl.text.trim();
              if (fromCtrl.text.trim().isNotEmpty)
                params['from'] = fromCtrl.text.trim();
              if (toCtrl.text.trim().isNotEmpty)
                params['to'] = toCtrl.text.trim();

              final minVal = double.tryParse(minCtrl.text.trim());
              if (minVal != null) params['min'] = minVal;

              final maxVal = double.tryParse(maxCtrl.text.trim());
              if (maxVal != null) params['max'] = maxVal;

              controller.applyFilter(params);
            },
            child: Text(
              'Apply filters'.tr,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: TextStyle(color: AppColors.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textMuted),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.8)),
          ),
        ),
      ),
    );
  }
}
