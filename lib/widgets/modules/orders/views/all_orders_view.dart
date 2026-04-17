import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../layout/admin_layout.dart';
import '../../../../layout/widgets/admin_page_header.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/orders_controller.dart';

class AllOrdersView extends StatefulWidget {
  const AllOrdersView({super.key});

  @override
  State<AllOrdersView> createState() => _AllOrdersViewState();
}

class _AllOrdersViewState extends State<AllOrdersView> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  // نفس اللي عندك + خلي "All" key ثابت
  final statuses = const [
    'all',
    'new',
    'assigned',
    'in_progress',
    'completed',
    'cancelled',
    'closed',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: ''.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminPageHeader(
            title: 'Orders',
            subtitle:
                'Review requests, check statuses, and move quickly between order workflows.',
            badges: [
              AdminInfoBadge(
                icon: Icons.filter_alt_outlined,
                label: '${'Filters'.tr}: ${statuses.length - 1}',
              ),
              AdminInfoBadge(
                icon: Icons.search,
                label: _query.trim().isEmpty
                    ? 'Search ready'.tr
                    : '${'Searching'.tr}: ${_query.trim()}',
                color: Colors.orange.shade700,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          _toolbar(
            isMobile: isMobile,
            onRefresh: controller.load,
            onClear: () {
              _searchCtrl.clear();
              setState(() => _query = '');
              // لو عندك method في controller للبحث نربطها هنا
              // controller.setQuery('');
              // controller.loadOrders();
            },
            searchField: SizedBox(
              width: isMobile ? double.infinity : 320,
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (v) {
                  // لو عندك API Search اربطه هنا:
                  // controller.setQuery(v);
                  // controller.loadOrders();
                },
                decoration: InputDecoration(
                  hintText: 'Search…'.tr,
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          icon: Icon(Icons.close, color: AppColors.textMuted),
                        ),
                ),
                style: TextStyle(color: AppColors.text),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.sm),

          // Status Filters (Premium Pills)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(
              () => Row(
                children: [
                  for (final s in statuses) ...[
                    _statusPill(
                      label: _statusLabel(s),
                      selected:
                          _normalizeFilterKey(controller.status.value) == s,
                      onTap: () => controller.setStatus(_toControllerStatus(s)),
                      color: _statusColor(s),
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Content
          Obx(() {
            if (controller.loading.value) {
              return const CardLoading(lines: 10);
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

            // فلترة محلية بالبحث (لو مش عندك Search API)
            final list = controller.orders;
            final filtered = _query.trim().isEmpty
                ? list
                : _filterOrders(list, _query);

            if (filtered.isEmpty) {
              return _emptyState(
                title: 'No orders'.tr,
                subtitle: _query.trim().isEmpty
                    ? 'No data'.tr
                    : 'No results'.tr,
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TableWrapper(
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Service'.tr)),
                      DataColumn(label: Text('Customer'.tr)),
                      DataColumn(label: Text('Artisan'.tr)),
                      DataColumn(label: Text('Status'.tr)),
                      DataColumn(label: Text('Date'.tr)),
                      DataColumn(label: Text('Actions'.tr)),
                    ],
                    rows: filtered.map((o) {
                      final service = (o['serviceType'] ?? o['service'] ?? '')
                          .toString();
                      final customer = _resolveName(o['customer']);
                      final artisan = _resolveName(o['artisan']);
                      final status = (o['status'] ?? '').toString();
                      final dateText = _formatDate(o['createdAt']);

                      return DataRow(
                        cells: [
                          DataCell(_cellText(service)),
                          DataCell(_cellText(customer)),
                          DataCell(_cellText(artisan)),
                          DataCell(_statusChip(status)),
                          DataCell(_cellText(dateText)),
                          DataCell(
                            Row(
                              spacing: 20,
                              children: [
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                    '/order/details',
                                    arguments: o,
                                  ),
                                  child: Text('Details'.tr),
                                ),
                                TextButton(
                                  onPressed: () => Get.toNamed(
                                    '/order/timeline',
                                    arguments: o,
                                  ),
                                  child: Text('Timeline'.tr),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    headingTextStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                    dataTextStyle: TextStyle(color: AppColors.text),
                    headingRowColor: MaterialStateProperty.all(
                      AppColors.overlay,
                    ),
                    dividerThickness: 0.2,
                  ),
                ),

                const SizedBox(height: AppSizes.sm),

                // Footer / Pagination placeholder
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${'Showing'.tr} ${filtered.length} ${'items'.tr}',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================

  Widget _toolbar({
    required bool isMobile,
    required VoidCallback onRefresh,
    required VoidCallback onClear,
    required Widget searchField,
  }) {
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            side: BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onClear,
          icon: Icon(
            Icons.cleaning_services_outlined,
            color: AppColors.textMuted,
            size: 18,
          ),
          label: Text('Clear'.tr),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: Text('Refresh'.tr),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [searchField, const SizedBox(height: 10), actions],
      );
    }

    return Row(children: [searchField, const Spacer(), actions]);
  }

  Widget _cellText(String value) {
    return Text(
      value.isEmpty ? '-' : value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600),
    );
  }

  Widget _emptyState({required String title, required String subtitle}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _statusPill({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.16) : AppColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.55)
                : AppColors.border.withOpacity(0.9),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: selected ? color : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.text : AppColors.textMuted,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    final key = _normalizeStatusKey(status);
    final color = _statusColor(key);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _statusLabel(key).tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================
  // Helpers
  // =========================

  List<dynamic> _filterOrders(List<dynamic> orders, String query) {
    final q = query.trim().toLowerCase();
    return orders.where((raw) {
      final o = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      final service = (o['serviceType'] ?? o['service'] ?? '')
          .toString()
          .toLowerCase();
      final customer = _resolveName(o['customer']).toLowerCase();
      final artisan = _resolveName(o['artisan']).toLowerCase();
      final status = (o['status'] ?? '').toString().toLowerCase();
      return service.contains(q) ||
          customer.contains(q) ||
          artisan.contains(q) ||
          status.contains(q);
    }).toList();
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

  String _resolveName(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['name'] ??
              value['customerName'] ??
              value['artisanName'] ??
              '')
          .toString();
    }
    return (value ?? '').toString();
  }

  // controller.status عندك كان بيبقى "All" كـ string
  String _normalizeFilterKey(dynamic status) {
    final s = (status ?? '').toString().trim().toLowerCase();
    if (s == 'all') return 'all';
    return s.replaceAll('-', '_').replaceAll(' ', '_');
  }

  // عشان ما نكسر Controller لو بيتوقع "All" مش "all"
  String _toControllerStatus(String key) {
    if (key == 'all') return 'All';
    return key;
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
        return normalized;
    }
  }

  String _statusLabel(String key) {
    switch (key) {
      case 'all':
        return 'All';
      case 'new':
        return 'New';
      case 'assigned':
        return 'Assigned';
      case 'in_progress':
        return 'In progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'closed':
        return 'Closed';
      default:
        return key;
    }
  }

  Color _statusColor(String key) {
    switch (key) {
      case 'completed':
        return AppColors.success;
      case 'new':
      case 'pending':
        return AppColors.warning;
      case 'assigned':
      case 'accepted':
      case 'active':
      case 'on_the_way':
        return Colors.lightBlueAccent;
      case 'in_progress':
      case 'working':
        return Colors.amber;
      case 'cancelled':
      case 'canceled':
      case 'rejected':
        return AppColors.danger;
      case 'closed':
        return AppColors.textMuted;
      case 'all':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }
}
