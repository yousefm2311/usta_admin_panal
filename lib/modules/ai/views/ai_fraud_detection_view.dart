import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../../../widgets/table_wrapper.dart';
import '../controllers/ai_fraud_controller.dart';

class AIFraudDetectionView extends StatelessWidget {
  const AIFraudDetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIFraudController());

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading(rows: 6, itemHeight: 48);
        }
        if (controller.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
          );
        }
        if (controller.cases.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fraud detection'.tr,
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSizes.md),
            TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Entity'.tr)),
                  DataColumn(label: Text('Score'.tr)),
                  DataColumn(label: Text('Reason'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text('Date'.tr)),
                ],
                rows: controller.cases
                    .map(
                      (c) => DataRow(
                        cells: [
                          DataCell(Text(_entityName(c))),
                          DataCell(Text(_score(c))),
                          DataCell(Text(_reason(c))),
                          DataCell(_statusChip(_field(c, ['status', 'state']))),
                          DataCell(Text(_field(c, ['createdAt', 'date', 'timestamp']))),
                        ],
                      ),
                    )
                    .toList(),
                headingTextStyle: const TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
                dataTextStyle: const TextStyle(color: AppColors.text),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _entityName(dynamic data) {
    if (data is Map<String, dynamic>) {
      final entity = data['entity'] ?? data['user'] ?? data['artisan'] ?? data['customer'];
      if (entity is Map<String, dynamic>) {
        return (entity['name'] ?? entity['fullName'] ?? entity['email'] ?? '').toString();
      }
      return (data['entityName'] ?? data['name'] ?? data['email'] ?? '').toString();
    }
    return '';
  }

  String _score(dynamic data) {
    final value = _field(data, ['score', 'risk', 'probability', 'value']);
    if (value.isEmpty) return '-';
    final parsed = double.tryParse(value);
    if (parsed == null) return value;
    return parsed.toStringAsFixed(2);
  }

  String _reason(dynamic data) {
    return _field(data, ['reason', 'message', 'note', 'description']);
  }

  String _field(dynamic data, List<String> keys) {
    if (data is Map<String, dynamic>) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }
    }
    return '';
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'high':
      case 'blocked':
        color = AppColors.danger;
        break;
      case 'medium':
        color = AppColors.warning;
        break;
      case 'low':
      case 'ok':
        color = AppColors.success;
        break;
      default:
        color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.isEmpty ? '-' : status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
