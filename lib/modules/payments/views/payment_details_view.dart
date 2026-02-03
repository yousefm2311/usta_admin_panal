import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/payment_details_controller.dart';

class PaymentDetailsView extends StatefulWidget {
  const PaymentDetailsView({super.key});

  @override
  State<PaymentDetailsView> createState() => _PaymentDetailsViewState();
}

class _PaymentDetailsViewState extends State<PaymentDetailsView> {
  late final PaymentDetailsController controller;
  String paymentId = '';
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(PaymentDetailsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    paymentId = (args?['_id'] ?? args?['id'] ?? '').toString();

    if (paymentId.isNotEmpty) {
      controller.load(paymentId);
      loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Payment details'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 220, lines: 8);
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

        final payment = controller.payment.value;
        if (payment == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final status = (payment['status'] ?? '').toString();
        final method = (payment['method'] ?? payment['paymentMethod'] ?? '')
            .toString();
        final amountText = _formatAmount(payment);
        final createdAt = payment['createdAt'] ?? payment['date'] ?? '';
        final createdAtText = _formatDatePretty(createdAt);

        final customerName = _resolveName(
          payment['customer'] ?? payment['customerId'],
        );
        final artisanName = _resolveName(
          payment['artisan'] ?? payment['artisanId'],
        );
        final reference = (payment['reference'] ?? payment['ref'] ?? '')
            .toString();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================
            Row(
              children: [
                Text(
                  'Payment details'.tr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.1,
                  ),
                ),
                const Spacer(),

                if (paymentId.isNotEmpty)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () =>
                        _copyToClipboard(paymentId, label: 'Payment ID'.tr),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text('Copy ID'.tr),
                  ),

                const SizedBox(width: AppSizes.sm),

                IconButton(
                  onPressed: paymentId.isEmpty
                      ? null
                      : () => controller.load(paymentId),
                  icon: Icon(Icons.refresh_rounded, color: AppColors.textMuted),
                  tooltip: 'Refresh'.tr,
                ),

                const SizedBox(width: AppSizes.sm),

                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textMuted,
                  ),
                  tooltip: 'Back'.tr,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Transaction overview and technical payload'.tr,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // =========================
            // SUMMARY CARD
            // =========================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // left summary
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount'.tr,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              amountText,
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _statusChip(status),
                                _methodChip(method),
                                if (createdAtText.isNotEmpty)
                                  _infoPill(
                                    Icons.schedule_rounded,
                                    createdAtText,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // right icon
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.payments_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // details grid
                  LayoutBuilder(
                    builder: (context, c) {
                      final twoCols = c.maxWidth >= 860;
                      return Column(
                        children: [
                          _kvRow('Status'.tr, status, twoCols: twoCols),
                          _kvRow('Method'.tr, method, twoCols: twoCols),
                          _kvRow('Customer'.tr, customerName, twoCols: twoCols),
                          _kvRow('Artisan'.tr, artisanName, twoCols: twoCols),
                          _kvRow(
                            'Date'.tr,
                            createdAtText.isEmpty
                                ? createdAt.toString()
                                : createdAtText,
                            twoCols: twoCols,
                          ),
                          _kvRow(
                            'Reference'.tr,
                            reference,
                            twoCols: twoCols,
                            copyValue: reference,
                          ),
                          if (paymentId.isNotEmpty)
                            _kvRow(
                              'ID'.tr,
                              paymentId,
                              twoCols: twoCols,
                              copyValue: paymentId,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // RAW PAYLOAD
            // =========================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Raw payload'.tr,
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          side: BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () => _copyToClipboard(
                          payment.toString(),
                          label: 'Raw payload'.tr,
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text('Copy'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.75),
                      ),
                    ),
                    child: SelectableText(
                      payment.toString(),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // UI HELPERS
  // =========================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _kvRow(
    String label,
    String value, {
    required bool twoCols,
    String? copyValue,
  }) {
    final v = value.trim().isEmpty ? '—' : value.trim();

    if (!twoCols) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSizes.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    v,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (copyValue != null && copyValue.trim().isNotEmpty)
                  IconButton(
                    onPressed: () => _copyToClipboard(copyValue, label: label),
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    tooltip: 'Copy'.tr,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(color: AppColors.border.withOpacity(0.7), height: 1),
          ],
        ),
      );
    }

    // two cols layout
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    v,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (copyValue != null && copyValue.trim().isNotEmpty)
                  IconButton(
                    onPressed: () => _copyToClipboard(copyValue, label: label),
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    tooltip: 'Copy'.tr,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
        style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 12),
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
        style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 12),
      ),
    );
  }

  // =========================
  // DATA HELPERS
  // =========================
  String _resolveName(dynamic value) {
    if (value is Map<String, dynamic>) {
      final name =
          value['name'] ??
          value['fullName'] ??
          value['email'] ??
          value['phone'];
      return (name ?? '').toString();
    }
    return value?.toString() ?? '';
  }

  String _formatAmount(Map<String, dynamic> payment) {
    final amount =
        payment['amount'] ??
        payment['finalAmount'] ??
        payment['total'] ??
        payment['value'] ??
        0;

    final parsed = double.tryParse(amount.toString()) ?? 0;

    // short formatting
    final abs = parsed.abs();
    String txt;
    if (abs >= 1000000) {
      txt = '${(parsed / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      txt = '${(parsed / 1000).toStringAsFixed(1)}K';
    } else {
      txt = parsed % 1 == 0
          ? parsed.toInt().toString()
          : parsed.toStringAsFixed(2);
    }

    return 'EGP $txt';
  }

  String _formatDatePretty(dynamic raw) {
    if (raw == null) return '';
    DateTime? dt;

    if (raw is DateTime) {
      dt = raw;
    } else {
      dt = DateTime.tryParse(raw.toString());
    }
    if (dt == null) return raw.toString();

    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');

    return '$yyyy-$mm-$dd  $hh:$mi';
  }

  Future<void> _copyToClipboard(String text, {required String label}) async {
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied'.tr,
      '$label ${'copied'.tr}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.card,
      colorText: AppColors.text,
      margin: const EdgeInsets.all(AppSizes.md),
      borderRadius: 14,
      duration: const Duration(seconds: 2),
    );
  }
}
