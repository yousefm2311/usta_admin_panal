import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../../withdrawals/controllers/withdrawals_controller.dart';

class PayoutRequestsView extends StatelessWidget {
  const PayoutRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WithdrawalsController());

    return AdminLayout(
      title: 'Payout Requests'.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading();
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

        if (controller.withdrawals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER
            // =========================
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payout requests'.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Approve or reject withdrawal requests'.tr,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onPressed: controller.loadWithdrawals,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('Refresh'.tr),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // TABLE
            // =========================
            TableWrapper(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Artisan'.tr)),
                    DataColumn(label: Text('Amount'.tr)),
                    DataColumn(label: Text('Method'.tr)),
                    DataColumn(label: Text('IBAN'.tr)),
                    DataColumn(label: Text('Status'.tr)),
                    DataColumn(label: Text('Actions'.tr)),
                  ],
                  rows: controller.withdrawals.map((raw) {
                    final p =
                        raw as Map<String, dynamic>? ?? <String, dynamic>{};

                    final status = (p['status'] ?? '').toString();
                    final canTakeAction = _isPendingStatus(status);

                    final id = controller.idFor(p);
                    final artisan = controller.artisanNameFor(p);
                    final amount = controller.amountFor(p);
                    final method = controller.methodFor(p);
                    final iban = controller.ibanFor(p);

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            artisan.isEmpty ? 'Unknown artisan'.tr : artisan,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(_amountText(amount)),
                        DataCell(_methodChip(method)),
                        DataCell(_ibanCell(iban)),
                        DataCell(_statusChip(status)),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (canTakeAction) ...[
                                TextButton(
                                  onPressed: id.isEmpty
                                      ? null
                                      : () => _confirmAction(
                                          context,
                                          title: 'Approve request'.tr,
                                          message:
                                              'Are you sure you want to approve this payout?'
                                                  .tr,
                                          confirmText: 'Approve'.tr,
                                          confirmColor: AppColors.success,
                                          onConfirm: () =>
                                              controller.approve(id),
                                        ),
                                  child: Text(
                                    'Approve'.tr,
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.xs),
                                TextButton(
                                  onPressed: id.isEmpty
                                      ? null
                                      : () => _confirmAction(
                                          context,
                                          title: 'Reject request'.tr,
                                          message:
                                              'Are you sure you want to reject this payout?'
                                                  .tr,
                                          confirmText: 'Reject'.tr,
                                          confirmColor: Colors.redAccent,
                                          onConfirm: () =>
                                              controller.reject(id),
                                        ),
                                  child: Text(
                                    'Reject'.tr,
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'No actions'.tr,
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
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
            ),
          ],
        );
      }),
    );
  }

  // =========================
  // UI HELPERS
  // =========================
  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();

    final isApproved = s == 'approved' || s == 'paid' || s == 'success';
    final isRejected =
        s == 'rejected' || s == 'failed' || s == 'cancelled' || s == 'canceled';
    final isPending = _isPendingStatus(status);

    final color = isApproved
        ? AppColors.success
        : isRejected
        ? Colors.redAccent
        : isPending
        ? AppColors.warning
        : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        (status.isEmpty ? '—' : status).tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  bool _isPendingStatus(String status) {
    final value = status.trim().toLowerCase();
    return value.isEmpty ||
        value == 'pending' ||
        value == 'review' ||
        value == 'in review' ||
        value == 'new';
  }

  Widget _amountText(dynamic value) {
    final n = double.tryParse(value.toString()) ?? 0;
    final abs = n.abs();

    String txt;
    if (abs >= 1000000) {
      txt = '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (abs >= 1000) {
      txt = '${(n / 1000).toStringAsFixed(1)}K';
    } else {
      txt = n % 1 == 0 ? n.toInt().toString() : n.toStringAsFixed(2);
    }

    return Text(
      'EGP $txt',
      style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
    );
  }

  Widget _methodChip(String method) {
    final value = method.trim();
    if (value.isEmpty) {
      return Text('—', style: TextStyle(color: AppColors.textMuted));
    }

    final m = value.toLowerCase();
    final isWithdraw = m.contains('withdraw');
    final isTransfer = m.contains('bank') || m.contains('transfer');
    final color = isWithdraw
        ? AppColors.warning
        : isTransfer
        ? AppColors.primary
        : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        value.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _ibanCell(String iban) {
    final masked = _maskIban(iban);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          masked.isEmpty ? '—' : masked,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700),
        ),
        if (iban.trim().isNotEmpty) ...[
          const SizedBox(width: 6),
          IconButton(
            onPressed: () => _copyToClipboard(iban, label: 'IBAN'.tr),
            icon: Icon(
              Icons.copy_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            tooltip: 'Copy'.tr,
          ),
        ],
      ],
    );
  }

  String _maskIban(String iban) {
    final v = iban.replaceAll(' ', '').trim();
    if (v.isEmpty) return '';
    if (v.length <= 8) return v;
    return '${v.substring(0, 4)}••••${v.substring(v.length - 4)}';
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

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textMuted, height: 1.35),
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
              onConfirm();
            },
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
