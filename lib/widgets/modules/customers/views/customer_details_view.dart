import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../core/utils/notify.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends StatefulWidget {
  const CustomerDetailsView({super.key});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  late final CustomerDetailsController controller;
  String customerId = '';
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CustomerDetailsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load only once (avoid reloading on rebuild)
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    customerId = (args?['_id'] ?? args?['id'] ?? '').toString();

    if (customerId.isNotEmpty) {
      controller.load(customerId);
      loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 280, lines: 10);
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

        final data = controller.customer.value;
        final stats = controller.derivedStats.value ?? <String, dynamic>{};

        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final allRequests = controller.customerRequests;
        final effectiveStats = stats.isNotEmpty
            ? stats
            : _statsFromRequests(allRequests);

        final isBlocked = data['blocked'] == true;
        final name = (data['name'] ?? '').toString();
        final phone = (data['phone'] ?? data['mobile'] ?? '').toString();
        final location = (data['location'] ?? data['preferredLocation'] ?? '')
            .toString();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // HEADER
              // =========================
              _card(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? '—' : name,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (phone.isNotEmpty)
                                _metaChip(
                                  icon: Icons.phone,
                                  text: phone,
                                  onCopy: () => _copyText(phone),
                                ),
                              if (location.isNotEmpty)
                                _metaChip(
                                  icon: Icons.location_on_outlined,
                                  text: location,
                                ),
                              _statusChip(isBlocked ? 'Blocked' : 'Active'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (isBlocked ? 'Blocked' : 'Active').tr,
                          style: TextStyle(
                            color: isBlocked
                                ? Colors.redAccent
                                : AppColors.success,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Access'.tr,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Switch(
                              value: !isBlocked,
                              onChanged: (val) => controller.blockToggle(
                                customerId,
                                block: !val,
                              ),
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // =========================
              // KPI GRID
              // =========================
              LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final cols = isMobile ? 2 : (w >= 1100 ? 4 : 2);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: cols,
                    crossAxisSpacing: AppSizes.md,
                    mainAxisSpacing: AppSizes.md,
                    childAspectRatio: cols == 2 ? 2.6 : 3.0,
                    children: [
                      _kpi(
                        title: 'Total requests label'.tr,
                        value: _formatNumber(
                          effectiveStats['total'] ??
                              data['requests'] ??
                              data['totalRequests'] ??
                              '0',
                        ),
                        icon: Icons.timeline,
                        color: AppColors.primary,
                      ),
                      _kpi(
                        title: 'Completed label'.tr,
                        value: _formatNumber(
                          effectiveStats['completed'] ??
                              data['completed'] ??
                              '',
                        ),
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                      _kpi(
                        title: 'Canceled'.tr,
                        value: _formatNumber(
                          effectiveStats['cancelled'] ?? data['canceled'] ?? '',
                        ),
                        icon: Icons.cancel_outlined,
                        color: Colors.redAccent,
                      ),
                      _kpi(
                        title: 'Lifetime spend'.tr,
                        value: _formatMoney(
                          effectiveStats['spend'] ??
                              data['lifetimeSpend'] ??
                              '',
                        ),
                        icon: Icons.payments_outlined,
                        color: Colors.teal.shade600,
                        prefix: 'EG ',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppSizes.md),

              // =========================
              // ORDERS PREVIEW
              // =========================
              _ordersSection(allRequests, customerId, name),

              const SizedBox(height: AppSizes.md),

              // =========================
              // FULL DETAILS (clean sections)
              // =========================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Full details'.tr,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _pill(icon: Icons.tune, text: 'Structured'.tr),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),

                    // ✅ New details UI
                    _detailsSections(data),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _detailsSections(Map<String, dynamic> data) {
    // ترتيب مفيد: الأول الحاجات الأهم
    final preferredOrder = <String>[
      'name',
      'phone',
      'email',
      'status',
      'blocked',
      'location',
      'preferredLocation',
      'createdAt',
      'updatedAt',
    ];

    final entries = data.entries.toList();

    entries.sort((a, b) {
      final ai = preferredOrder.indexOf(a.key);
      final bi = preferredOrder.indexOf(b.key);
      if (ai == -1 && bi == -1) return a.key.compareTo(b.key);
      if (ai == -1) return 1;
      if (bi == -1) return -1;
      return ai.compareTo(bi);
    });

    return Column(
      children: entries.map((e) {
        final key = _prettyKey(e.key);
        final value = e.value;

        return _sectionCard(
          title: key,
          content: _renderAnyValue(key, value),
          meta: _valueMeta(value),
        );
      }).toList(),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget content,
    required String meta,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Theme(
        data: Theme.of(Get.context!).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          iconColor: AppColors.textMuted,
          collapsedIconColor: AppColors.textMuted,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              _metaBadge(meta),
            ],
          ),
          children: [content],
        ),
      ),
    );
  }

  Widget _metaBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _renderAnyValue(String label, dynamic value) {
    if (value == null) return _valueBox(label, '-');

    if (value is Map) {
      // Key/Value grid
      final entries = value.entries.toList();
      return _kvGrid(
        entries.map((e) {
          return (_prettyKey(e.key.toString()), _formatSimple(e.value));
        }).toList(),
      );
    }

    if (value is List) {
      return _listPreview(label, value);
    }

    // Simple value
    final txt = _formatSimple(value);
    return _valueBox(label, txt);
  }

  Widget _kvGrid(List<(String k, String v)> items) {
    if (items.isEmpty) {
      return _valueBox(''.tr, '-');
    }

    return Column(
      children: [
        for (final it in items)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.75)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  child: Text(
                    it.$1,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    it.$2.isEmpty ? '-' : it.$2,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (_canCopyValue(it.$1, it.$2))
                  IconButton(
                    tooltip: 'Copy'.tr,
                    onPressed: () => _copyText(it.$2),
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _listPreview(String label, List list) {
    if (list.isEmpty) return _valueBox(label, '0');

    final preview = list.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _valueBox('Count'.tr, list.length.toString(), dense: true),
        const SizedBox(height: 10),

        for (var i = 0; i < preview.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.75)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 26,
                  width: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _summarizeItem(preview[i]),
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_canCopyValue('Item'.tr, _summarizeItem(preview[i])))
                  IconButton(
                    tooltip: 'Copy'.tr,
                    onPressed: () => _copyText(_summarizeItem(preview[i])),
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

        if (list.length > 5)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+ ${list.length - 5} more'.tr,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _valueBox(String label, String value, {bool dense = false}) {
    return Container(
      padding: EdgeInsets.all(dense ? 10 : 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.75)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.trim().isNotEmpty) ...[
            SizedBox(
              width: 160,
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: AppColors.text,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (_canCopyValue(label, value))
            IconButton(
              tooltip: 'Copy'.tr,
              onPressed: () => _copyText(value),
              icon: Icon(Icons.copy, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  String _prettyKey(String key) {
    // key formatting + capitalization
    final cleaned = key.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return '-';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  String _valueMeta(dynamic value) {
    if (value == null) return 'null';
    if (value is Map) return 'map • ${value.length}';
    if (value is List) return 'list • ${value.length}';
    if (value is bool) return 'bool';
    if (value is num) return 'num';
    if (value is String) {
      final s = value.trim();
      if (s.isEmpty) return 'text • 0';
      return 'text • ${min(99, s.length)}';
    }
    return value.runtimeType.toString().toLowerCase();
  }

  // =====================================================
  // UI Components
  // =====================================================
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    VoidCallback? onCopy,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.copy, size: 14, color: AppColors.textMuted),
            ],
          ],
        ),
      ),
    );
  }

  Widget _kpi({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String prefix = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$prefix$value',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();
    final bool active = s == 'active';
    final bool blocked = s == 'blocked';

    final color = active
        ? AppColors.success
        : blocked
        ? Colors.redAccent
        : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  // =====================================================
  // Orders preview
  // =====================================================
  Widget _ordersSection(
    List<dynamic> requests,
    String customerId,
    String customerName,
  ) {
    final preview = requests.length > 5 ? requests.take(5).toList() : requests;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Orders list'.tr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(
                  '/customer/orders',
                  arguments: {'id': customerId, 'name': customerName},
                ),
                child: Text('View all'.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (preview.isEmpty)
            Text('No data'.tr, style: TextStyle(color: AppColors.textMuted))
          else
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Service'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                ],
                rows: preview.map((raw) {
                  final r = raw is Map<String, dynamic>
                      ? raw
                      : <String, dynamic>{};

                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (r['serviceType'] ?? r['service'] ?? '').toString(),
                        ),
                      ),
                      DataCell(
                        _orderStatusChip((r['status'] ?? '').toString()),
                      ),
                      DataCell(Text(_formatMoney(_extractAmount(r)))),
                      DataCell(Text(_formatDate(r['createdAt']))),
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
      ),
    );
  }

  Widget _orderStatusChip(String status) {
    final s = status.toLowerCase().trim();
    Color color = AppColors.primary;

    if (s == 'completed' || s == 'closed') color = AppColors.success;
    if (s == 'cancelled' || s == 'canceled' || s == 'rejected') {
      color = Colors.redAccent;
    }
    if (s == 'pending' || s == 'new') color = Colors.amber.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        (status.isEmpty ? '—' : status).tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  // =====================================================
  // Stats / formatting helpers
  // =====================================================
  Map<String, dynamic> _statsFromRequests(List<dynamic> requests) {
    int total = 0;
    int completed = 0;
    int cancelled = 0;
    double spend = 0;

    for (final raw in requests) {
      final r = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      total += 1;

      final status = (r['status'] ?? '').toString().toLowerCase();
      if (status == 'completed' || status == 'closed') {
        completed += 1;
      } else if (status == 'cancelled' ||
          status == 'canceled' ||
          status == 'rejected') {
        cancelled += 1;
      }

      final amount = _extractAmount(r);
      final price = double.tryParse(amount?.toString() ?? '');
      if (price != null && price > 0) spend += price;
    }

    return {
      'total': total,
      'completed': completed,
      'cancelled': cancelled,
      'spend': spend,
    };
  }

  dynamic _extractAmount(Map<String, dynamic> r) {
    return r['agreedPrice'] ??
        r['price'] ??
        r['amount'] ??
        r['total'] ??
        r['pricing']?['proposedPrice'] ??
        '';
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

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    if (parsed % 1 == 0) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  String _formatMoney(dynamic value) {
    if (value == null || value.toString().isEmpty) return '-';
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return parsed % 1 == 0
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(2);
  }

  String _formatSimple(dynamic value) {
    if (value == null) return '-';
    if (value is String) return value.isEmpty ? '-' : value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  String _summarizeItem(dynamic value) {
    if (value is Map) {
      final name = value['name'] ?? value['title'];
      final id = value['_id'] ?? value['id'];
      if (name != null && id != null)
        return '${name.toString()} (${id.toString()})';
      if (name != null) return name.toString();
      if (id != null) return id.toString();
    }
    return _formatSimple(value);
  }

  bool _canCopyValue(String label, String value) {
    if (value.isEmpty || value == '-') return false;
    final lower = label.toLowerCase();
    if (lower.contains('email') ||
        lower.contains('phone') ||
        lower.contains('token')) {
      return true;
    }
    if (label.contains('ايميل') ||
        label.contains('بريد') ||
        label.contains('هاتف') ||
        label.contains('موبايل') ||
        label.contains('توكن')) {
      return true;
    }
    return _looksLikeToken(value);
  }

  bool _looksLikeToken(String value) {
    final trimmed = value.trim();
    if (trimmed.length < 20) return false;
    if (trimmed.contains(' ')) return false;
    return trimmed.contains(':') ||
        trimmed.startsWith('APA') ||
        trimmed.startsWith('eyJ');
  }

  Future<void> _copyText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    showSuccess('Copied'.tr);
  }
}
