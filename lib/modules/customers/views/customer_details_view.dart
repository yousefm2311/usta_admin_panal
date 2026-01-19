import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends StatefulWidget {
  const CustomerDetailsView({super.key});

  @override
  State<CustomerDetailsView> createState() => _CustomerDetailsViewState();
}

class _CustomerDetailsViewState extends State<CustomerDetailsView> {
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final isMobile = Responsive.isMobile(context);
    final controller = Get.put(CustomerDetailsController());
    if (id.isNotEmpty) controller.load(id);

    return AdminLayout(
      title: ''.tr,
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 260, lines: 10);
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
              style: const TextStyle(color: AppColors.textMuted),
            ),
          );
        }
        final allRequests = controller.customerRequests;
        final effectiveStats =
            stats.isNotEmpty ? stats : _statsFromRequests(allRequests);
        final isBlocked = data['blocked'] == true;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Customer details'.tr,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: AppSizes.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(
                          AppSizes.cardRadius,
                        ),
                        border: const Border.fromBorderSide(
                          BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.16,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (data['name'] ?? '').toString(),
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isBlocked ? 'Blocked'.tr : 'Active'.tr,
                                    style: TextStyle(
                                      color: isBlocked
                                          ? AppColors.danger
                                          : AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Switch(
                                value: !isBlocked,
                                onChanged: (val) =>
                                    controller.blockToggle(id, block: !val),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Wrap(
                            spacing: AppSizes.md,
                            runSpacing: AppSizes.md,
                            children: [
                              _stat(
                                'Total requests label'.tr,
                                _formatNumber(
                                  effectiveStats['total'] ??
                                      data['requests'] ??
                                      data['totalRequests'] ??
                                      '0',
                                ),
                              ),
                              _stat(
                                'Completed label'.tr,
                                _formatNumber(
                                  effectiveStats['completed'] ??
                                      data['completed'] ??
                                      '',
                                ),
                              ),
                              _stat(
                                'Canceled'.tr,
                                _formatNumber(
                                  effectiveStats['cancelled'] ??
                                      data['canceled'] ??
                                      '',
                                ),
                              ),
                              _stat(
                                'Lifetime spend'.tr,
                                _formatMoney(
                                  effectiveStats['spend'] ??
                                      data['lifetimeSpend'] ??
                                      '',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            (data['location'] ??
                                    data['preferredLocation'] ??
                                    '')
                                .toString(),
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isMobile) const SizedBox(width: AppSizes.md),
                ],
              ),
              const SizedBox(height: AppSizes.md),
              _ordersSection(allRequests, id, (data['name'] ?? '').toString()),
              const SizedBox(height: AppSizes.md),
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: const Border.fromBorderSide(
                    BorderSide(color: AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full details'.tr,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    ..._buildDetailRows(data),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = status.toLowerCase() == 'completed'
        ? AppColors.success
        : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.tr,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _ordersSection(
    List<dynamic> requests,
    String customerId,
    String customerName,
  ) {
    final preview = requests.length > 4 ? requests.take(4).toList() : requests;
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(
          BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Orders list'.tr,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(
                  '/customer/orders',
                  arguments: {
                    'id': customerId,
                    'name': customerName,
                  },
                ),
                child: Text('View all'.tr),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (preview.isEmpty)
            Text(
              'No data'.tr,
              style: const TextStyle(color: AppColors.textMuted),
            )
          else
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Service'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Amount'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                ],
                rows: preview
                    .map(
                      (raw) {
                        final r = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
                        return DataRow(
                          cells: [
                            DataCell(Text((r['serviceType'] ?? r['service'] ?? '').toString())),
                            DataCell(_statusChip((r['status'] ?? '').toString())),
                            DataCell(Text(_formatMoney(_extractAmount(r)))),
                            DataCell(Text(_formatDate(r['createdAt']))),
                          ],
                        );
                      },
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

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
      } else if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
        cancelled += 1;
      }
      final amount = _extractAmount(r);
      final price = double.tryParse(amount?.toString() ?? '');
      if (price != null && price > 0) {
        spend += price;
      }
    }

    return {
      'total': total,
      'completed': completed,
      'cancelled': cancelled,
      'spend': spend,
    };
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

  dynamic _extractAmount(Map<String, dynamic> r) {
    return r['agreedPrice'] ??
        r['price'] ??
        r['amount'] ??
        r['total'] ??
        r['pricing']?['proposedPrice'] ??
        '';
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
    return parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toStringAsFixed(2);
  }

  List<Widget> _buildDetailRows(Map<String, dynamic> data) {
    final rows = <Widget>[];
    for (final entry in data.entries) {
      final key = _labelKey(entry.key);
      final value = entry.value;
      if (value is Map) {
        rows.add(_sectionHeader(key));
        rows.addAll(_mapRows(value));
      } else if (value is List) {
        rows.add(_sectionHeader(key));
        rows.addAll(_listRows(value));
      } else {
        rows.add(_infoRow(key, _formatSimple(value)));
      }
    }
    return rows;
  }

  List<Widget> _mapRows(Map<dynamic, dynamic> map) {
    final rows = <Widget>[];
    for (final entry in map.entries) {
      rows.add(_infoRow('  ${_labelKey(entry.key.toString())}', _formatSimple(entry.value)));
    }
    return rows;
  }

  List<Widget> _listRows(List<dynamic> list) {
    if (list.isEmpty) {
      return [_infoRow('  ${"Count".tr}', '0')];
    }
    final rows = <Widget>[
      _infoRow('  ${"Count".tr}', list.length.toString()),
    ];
    final preview = list.take(5).toList();
    for (var i = 0; i < preview.length; i++) {
      rows.add(_infoRow('  ${"Item".tr} ${i + 1}', _summarizeItem(preview[i])));
    }
    return rows;
  }

  String _summarizeItem(dynamic value) {
    if (value is Map) {
      final name = value['name'] ?? value['title'];
      final id = value['_id'] ?? value['id'];
      if (name != null && id != null) {
        return '${name.toString()} (${id.toString()})';
      }
      if (name != null) return name.toString();
      if (id != null) return id.toString();
    }
    return _formatSimple(value);
  }

  String _formatSimple(dynamic value) {
    if (value == null) return '-';
    if (value is String) return value.isEmpty ? '-' : value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs, top: AppSizes.sm),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _labelKey(String key) {
    return key.replaceAll('_', ' ');
  }

  Widget _infoRow(String label, String value) {
    final canCopy = _canCopyValue(label, value);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: AppColors.text),
            ),
          ),
          if (canCopy)
            IconButton(
              tooltip: 'Copy'.tr,
              onPressed: () => _copyText(value),
              icon: const Icon(Icons.copy, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

  bool _canCopyValue(String label, String value) {
    if (value.isEmpty || value == '-') return false;
    final lower = label.toLowerCase();
    if (lower.contains('email') || lower.contains('phone') || lower.contains('token')) {
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
    return trimmed.contains(':') || trimmed.startsWith('APA') || trimmed.startsWith('eyJ');
  }

  Future<void> _copyText(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    showSuccess('Copied'.tr);
  }
}
