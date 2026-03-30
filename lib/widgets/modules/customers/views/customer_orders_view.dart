import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/customer_orders_controller.dart';

class CustomerOrdersView extends StatefulWidget {
  const CustomerOrdersView({super.key});

  @override
  State<CustomerOrdersView> createState() => _CustomerOrdersViewState();
}

class _CustomerOrdersViewState extends State<CustomerOrdersView> {
  late final CustomerOrdersController controller;

  String customerId = '';
  String customerName = '';

  // UI state (local)
  final RxString query = ''.obs;
  final RxString statusFilter = 'all'.obs;
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomerOrdersController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    customerId = (args['_id'] ?? args['id'] ?? '').toString();
    customerName = (args['name'] ?? '').toString();

    if (customerId.isNotEmpty) {
      controller.load(customerId);
      loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(lines: 8);
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

        final orders = controller.orders.map((e) {
          return e is Map<String, dynamic> ? e : <String, dynamic>{};
        }).toList();

        // sort: newest first (best UX)
        orders.sort((a, b) {
          final ad = DateTime.tryParse((a['createdAt'] ?? '').toString());
          final bd = DateTime.tryParse((b['createdAt'] ?? '').toString());
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });

        final filtered = _applyFilters(
          orders,
          q: query.value,
          status: statusFilter.value,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // HEADER CARD
            // =========================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          customerName.isEmpty
                              ? 'Orders list'.tr
                              : '${'Orders list'.tr}: $customerName',
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      _pill(icon: Icons.receipt_long, text: '${orders.length}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse, filter, and open order details.'.tr,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: AppSizes.md),

                  Row(
                    children: [
                      // Search
                      Expanded(
                        child: TextField(
                          onChanged: (v) => query.value = v,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textMuted,
                            ),
                            hintText: 'Search service or status'.tr,
                            hintStyle: TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.overlay,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.inputRadius,
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.inputRadius,
                              ),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.inputRadius,
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary.withOpacity(0.8),
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.sm),

                      // Status filter
                      SizedBox(
                        width: 200,
                        child: Obx(() {
                          return DropdownButtonFormField<String>(
                            value: statusFilter.value,
                            items: [
                              _dd('all', 'All'.tr),
                              _dd('completed', 'completed'.tr),
                              _dd('pending', 'pending'.tr),
                              _dd('new', 'new'.tr),
                              _dd('accepted', 'accepted'.tr),
                              _dd('on_the_way', 'on_the_way'.tr),
                              _dd('in_progress', 'in_progress'.tr),
                              _dd('cancelled', 'cancelled'.tr),
                              _dd('rejected', 'rejected'.tr),
                              _dd('closed', 'closed'.tr),
                            ],
                            onChanged: (v) => statusFilter.value = v ?? 'all',
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.overlay,
                              labelText: 'Status'.tr,
                              labelStyle: TextStyle(color: AppColors.textMuted),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.inputRadius,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSizes.inputRadius,
                                ),
                                borderSide: BorderSide(color: AppColors.border),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.md),

            // =========================
            // TABLE
            // =========================
            if (orders.isEmpty)
              _card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'No data'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else if (filtered.isEmpty)
              _card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'No results'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              TableWrapper(
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Service'.tr)),
                    DataColumn(label: Text('Status'.tr)),
                    DataColumn(label: Text('Amount'.tr)),
                    DataColumn(label: Text('Date'.tr)),
                    const DataColumn(label: Text('')),
                  ],
                  rows: filtered.map((r) {
                    final service = (r['serviceType'] ?? r['service'] ?? '')
                        .toString();
                    final status = (r['status'] ?? '').toString();
                    final amount = _formatMoney(_extractAmount(r));
                    final date = _formatDate(r['createdAt']);

                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.12,
                                ),
                                child: Icon(
                                  Icons.build,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Text(
                                  service,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(_statusChip(status)),
                        DataCell(
                          Text(
                            amount,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        DataCell(Text(date)),
                        DataCell(
                          Align(
                            alignment: Alignment.centerRight,
                            child: _actionsMenu(r),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  headingRowColor: MaterialStateProperty.all(AppColors.overlay),
                  headingTextStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                  dataTextStyle: TextStyle(color: AppColors.text),
                  dividerThickness: 0.25,
                  columnSpacing: 18,
                ),
              ),
          ],
        );
      }),
    );
  }

  // =========================
  // UI
  // =========================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
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

  Widget _pill({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _dd(String v, String label) {
    return DropdownMenuItem<String>(
      value: v,
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }

  Widget _actionsMenu(Map<String, dynamic> order) {
    return PopupMenuButton<_OrderAction>(
      tooltip: 'Actions'.tr,
      icon: Icon(Icons.more_horiz, color: AppColors.text),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (action) {
        switch (action) {
          case _OrderAction.details:
            Get.toNamed('/order/details', arguments: order);
            break;
          case _OrderAction.timeline:
            Get.toNamed('/order/timeline', arguments: order);
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _OrderAction.details,
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.text),
              const SizedBox(width: 10),
              Text('Details'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: _OrderAction.timeline,
          child: Row(
            children: [
              Icon(Icons.timeline, color: AppColors.text),
              const SizedBox(width: 10),
              Text('Timeline'.tr),
            ],
          ),
        ),
      ],
    );
  }

  // =========================
  // Filtering
  // =========================
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> orders, {
    required String q,
    required String status,
  }) {
    final qq = q.trim().toLowerCase();
    final st = status.trim().toLowerCase();

    bool statusOk(Map<String, dynamic> r) {
      if (st == 'all') return true;
      final s = _normalizeStatusKey((r['status'] ?? '').toString());
      return s == st;
    }

    bool queryOk(Map<String, dynamic> r) {
      if (qq.isEmpty) return true;
      final service = (r['serviceType'] ?? r['service'] ?? '')
          .toString()
          .toLowerCase();
      final statusText = (r['status'] ?? '').toString().toLowerCase();
      return service.contains(qq) || statusText.contains(qq);
    }

    return orders.where((r) => statusOk(r) && queryOk(r)).toList();
  }

  // =========================
  // Formatting helpers
  // =========================
  String _formatDate(dynamic value) {
    if (value is DateTime) return '${value.day}/${value.month}/${value.year}';
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return '${parsed.day}/${parsed.month}/${parsed.year}';
      return value;
    }
    return '';
  }

  dynamic _extractAmount(Map<String, dynamic> r) {
    return r['agreedPrice'] ??
        r['price'] ??
        r['amount'] ??
        r['total'] ??
        r['pricing']?['proposedPrice'] ??
        '';
  }

  String _formatMoney(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed % 1 == 0
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(2);
  }

  Widget _statusChip(String status) {
    final key = _normalizeStatusKey(status);
    final color = _statusColor(key);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        key.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  String _normalizeStatusKey(String status) {
    final normalized = status
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      case 'inprogress':
      case 'in_progress':
        return 'in_progress';
      case 'on_the_way':
        return 'on_the_way';
      case 'cancelled':
      case 'canceled':
        return 'cancelled';
      default:
        return normalized.isEmpty ? 'unknown' : normalized;
    }
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'completed':
        return AppColors.success;
      case 'pending':
      case 'new':
        return AppColors.warning;
      case 'assigned':
      case 'accepted':
      case 'active':
      case 'on_the_way':
        return Colors.lightBlueAccent;
      case 'in_progress':
      case 'working':
        return Colors.amber;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return AppColors.danger;
      case 'closed':
        return AppColors.textMuted;
      default:
        return AppColors.primary;
    }
  }
}

enum _OrderAction { details, timeline }
