import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/customers_controller.dart';

class CustomersListView extends StatelessWidget {
  const CustomersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomersController());

    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // HEADER (Title + Search)
          // =========================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;

                    final title = Text(
                      'Customers list'.tr,
                      style: TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    );

                    final searchField = SizedBox(
                      width: isNarrow ? double.infinity : 320,
                      child: TextField(
                        onChanged: controller.setQuery,
                        onSubmitted: (v) => controller.loadCustomers(
                          search: v.trim().isEmpty ? null : v.trim(),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textMuted,
                          ),
                          hintText: 'Search by name or phone'.tr,
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.overlay,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.inputRadius,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.inputRadius,
                            ),
                            borderSide: BorderSide(
                              color: AppColors.border,
                              width: 1,
                            ),
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
                          suffixIcon: IconButton(
                            tooltip: 'Search'.tr,
                            icon: Icon(
                              Icons.arrow_forward,
                              color: AppColors.text,
                            ),
                            onPressed: () => controller.loadCustomers(
                              search: controller.query.value.trim().isEmpty
                                  ? null
                                  : controller.query.value.trim(),
                            ),
                          ),
                        ),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          const SizedBox(height: AppSizes.sm),
                          searchField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: title),
                        const SizedBox(width: AppSizes.sm),
                        searchField,
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppSizes.sm),

                Text(
                  'Manage customers, view details, and control access.'.tr,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),

                const SizedBox(height: AppSizes.md),

                // =========================
                // MINI KPI ROW (auto calc)
                // =========================
                Obx(() {
                  if (controller.loading.value ||
                      controller.customers.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final total = controller.customers.length;
                  final blocked = controller.customers
                      .where(
                        (c) =>
                            (c['blocked'] == true) ||
                            (c['status'] == 'Blocked'),
                      )
                      .length;
                  final active = total - blocked;

                  return Wrap(
                    spacing: AppSizes.sm,
                    runSpacing: AppSizes.sm,
                    children: [
                      _miniStat(
                        title: 'Total'.tr,
                        value: total.toString(),
                        color: AppColors.primary,
                        icon: Icons.group_outlined,
                      ),
                      _miniStat(
                        title: 'Active'.tr,
                        value: active.toString(),
                        color: AppColors.success,
                        icon: Icons.verified_outlined,
                      ),
                      _miniStat(
                        title: 'Blocked'.tr,
                        value: blocked.toString(),
                        color: Colors.redAccent,
                        icon: Icons.block_outlined,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // =========================
          // TABLE
          // =========================
          Obx(() {
            if (controller.loading.value) {
              return const ShimmerListPlaceholder(rows: 7, itemHeight: 58);
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
            if (controller.customers.isEmpty) {
              return _card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Text(
                    'No data'.tr,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return TableWrapper(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Customer'.tr)),
                  DataColumn(label: Text('Phone'.tr)),
                  DataColumn(label: Text('Requests'.tr)),
                  DataColumn(label: Text('Status'.tr)),
                  DataColumn(label: Text(''.tr)),
                ],
                rows: controller.customers.map((customer) {
                  final status =
                      customer['status'] ??
                      (customer['blocked'] == true ? 'Blocked' : 'Active');

                  final isBlocked =
                      customer['blocked'] == true || status == 'Blocked';
                  final id = (customer['id'] ?? customer['_id'] ?? '')
                      .toString();

                  final localCount =
                      customer['requestsCount'] ??
                      customer['totalRequests'] ??
                      customer['requests_count'] ??
                      customer['ordersCount'] ??
                      customer['orders_count'] ??
                      customer['requests'] ??
                      (customer['requests'] is List
                          ? (customer['requests'] as List).length
                          : 0);

                  final apiCount = id.isNotEmpty
                      ? controller.requestCounts[id]
                      : null;

                  final isCountLoading =
                      controller.requestsCountLoadingAll.value ||
                      (id.isNotEmpty &&
                          controller.requestCountsLoading[id] == true);

                  final name =
                      (customer['name'] ??
                              customer['fullName'] ??
                              customer['displayName'] ??
                              customer['username'] ??
                              customer['email'] ??
                              customer['phone'] ??
                              '')
                          .toString();
                  final phone =
                      (customer['phone'] ??
                              customer['phoneNumber'] ??
                              customer['mobile'] ??
                              customer['customerPhone'] ??
                              '')
                          .toString();

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.12,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                name,
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
                      DataCell(
                        Text(phone, style: TextStyle(color: AppColors.text)),
                      ),
                      DataCell(
                        Text(
                          isCountLoading
                              ? '...'
                              : (apiCount ?? localCount).toString(),
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(_statusChip(status.toString())),
                      DataCell(
                        Align(
                          alignment: Alignment.centerRight,
                          child: _actionsMenu(
                            context: context,
                            controller: controller,
                            id: id,
                            isBlocked: isBlocked,
                            customer: customer,
                          ),
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
                headingRowColor: MaterialStateProperty.all(AppColors.overlay),
                dividerThickness: 0.25,
                columnSpacing: 20,
              ),
            );
          }),

          const SizedBox(height: AppSizes.md),

          // =========================
          // PAGINATION (UI only)
          // =========================
          Align(
            alignment: Alignment.centerRight,
            child: _card(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(color: AppColors.border),
                    ),
                    onPressed: () {
                      // اربطها بعدين بـ controller (page--)
                    },
                    icon: const Icon(Icons.chevron_left),
                    label: Text('Prev'.tr),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.text,
                      side: BorderSide(color: AppColors.border),
                    ),
                    onPressed: () {
                      // اربطها بعدين بـ controller (page++)
                    },
                    icon: const Icon(Icons.chevron_right),
                    label: Text('Next'.tr),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // UI PARTS
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

  Widget _miniStat({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final s = status.toLowerCase().trim();
    final bool isActive = s == 'active';
    final bool isBlocked = s == 'blocked';

    final color = isActive
        ? AppColors.success
        : isBlocked
        ? Colors.redAccent
        : AppColors.textMuted;

    final label = isActive
        ? 'Active'.tr
        : isBlocked
        ? 'Blocked'.tr
        : status.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _actionsMenu({
    required BuildContext context,
    required CustomersController controller,
    required String id,
    required bool isBlocked,
    required Map<String, dynamic> customer,
  }) {
    return PopupMenuButton<_CustomerAction>(
      tooltip: 'Actions'.tr,
      icon: Icon(Icons.more_horiz, color: AppColors.text),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (action) {
        switch (action) {
          case _CustomerAction.view:
            Get.toNamed('/customer/details', arguments: customer);
            break;
          case _CustomerAction.blockToggle:
            controller.blockCustomer(id, block: !isBlocked);
            break;
          case _CustomerAction.delete:
            _confirmDelete(context, controller, id);
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _CustomerAction.view,
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.text),
              const SizedBox(width: 10),
              Text('View details'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CustomerAction.blockToggle,
          child: Row(
            children: [
              Icon(
                isBlocked ? Icons.lock_open : Icons.block_outlined,
                color: isBlocked ? AppColors.success : Colors.redAccent,
              ),
              const SizedBox(width: 10),
              Text(isBlocked ? 'Unblock'.tr : 'Block'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CustomerAction.delete,
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.redAccent),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    CustomersController controller,
    String id,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.border),
        ),
        title: Text(
          'Delete'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Delete this customer?'.tr,
          style: TextStyle(color: AppColors.textMuted),
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
              controller.deleteCustomer(id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CustomerAction { view, blockToggle, delete }
