import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../../../table_wrapper.dart';
import '../controllers/artisans_controller.dart';

class ArtisansListView extends StatefulWidget {
  const ArtisansListView({super.key});

  @override
  State<ArtisansListView> createState() => _ArtisansListViewState();
}

class _ArtisansListViewState extends State<ArtisansListView> {
  late final ArtisansController controller;

  final RxString query = ''.obs;
  final RxString statusFilter = 'all'.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ArtisansController());
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: '',
      child: Column(
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
                        'Artisans'.tr,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh'.tr,
                      onPressed: controller.loadArtisans,
                      icon: Icon(Icons.refresh, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Review artisans, approve pending profiles, or suspend accounts.'
                      .tr,
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
                          hintText: 'Search by name or category'.tr,
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

                    // Status Filter
                    SizedBox(
                      width: 220,
                      child: Obx(() {
                        return DropdownButtonFormField<String>(
                          value: statusFilter.value,
                          onChanged: (v) => statusFilter.value = v ?? 'all',
                          items: [
                            _dd('all', 'All'.tr),
                            _dd('pending', 'Pending'.tr),
                            _dd('approved', 'Approved'.tr),
                            _dd('active', 'Active'.tr),
                            _dd('rejected', 'Rejected'.tr),
                            _dd('blocked', 'Blocked'.tr),
                            _dd('suspended', 'Suspended'.tr),
                            _dd('inactive', 'Inactive'.tr),
                          ],
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
          // BODY
          // =========================
          Obx(() {
            if (controller.loading.value) {
              return const ListLoading(itemHeight: 58);
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
            if (controller.artisans.isEmpty) {
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

            final all = controller.artisans.map((e) {
              return e is Map<String, dynamic> ? e : <String, dynamic>{};
            }).toList();

            final filtered = _applyFilters(
              all,
              q: query.value,
              status: statusFilter.value,
            );

            final kpis = _computeKpis(all);

            return Column(
              children: [
                // KPIs
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.sm,
                  children: [
                    _miniStat(
                      title: 'Total'.tr,
                      value: kpis.total.toString(),
                      color: AppColors.primary,
                      icon: Icons.group_outlined,
                    ),
                    _miniStat(
                      title: 'Pending'.tr,
                      value: kpis.pending.toString(),
                      color: AppColors.warning,
                      icon: Icons.hourglass_bottom,
                    ),
                    _miniStat(
                      title: 'Approved'.tr,
                      value: kpis.approved.toString(),
                      color: AppColors.success,
                      icon: Icons.verified_outlined,
                    ),
                    _miniStat(
                      title: 'Suspended'.tr,
                      value: kpis.suspended.toString(),
                      color: AppColors.textMuted,
                      icon: Icons.pause_circle_outline,
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.md),

                if (filtered.isEmpty)
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
                        DataColumn(label: Text('Artisan'.tr)),
                        DataColumn(label: Text('Category'.tr)),
                        DataColumn(label: Text('Rating'.tr)),
                        DataColumn(label: Text('Status'.tr)),
                        const DataColumn(label: Text('')),
                      ],
                      rows: filtered.map((artisan) {
                        final id = (artisan['id'] ?? artisan['_id'] ?? '')
                            .toString();

                        final reviewRating = id.isNotEmpty
                            ? controller.artisanRatings[id]
                            : null;
                        final rating =
                            reviewRating ??
                            artisan['rating'] ??
                            artisan['score'] ??
                            0;

                        final profession =
                            (artisan['category'] ?? artisan['profession'] ?? '')
                                .toString();

                        final status = _resolveStatus(artisan);
                        final canTakeAction = _isPendingStatus(status);
                        final isSuspended = _isTruthy(artisan['suspended']);

                        final name = (artisan['name'] ?? '').toString();

                        return DataRow(
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.12),
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
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(profession)),
                            DataCell(_ratingCell(rating)),
                            DataCell(_statusChip(status)),
                            DataCell(
                              Align(
                                alignment: Alignment.centerRight,
                                child: _actionsMenu(
                                  artisan: artisan,
                                  id: id,
                                  status: status,
                                  canTakeAction: canTakeAction,
                                  isSuspended: isSuspended,
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
                      headingRowColor: MaterialStateProperty.all(
                        AppColors.overlay,
                      ),
                      dividerThickness: 0.25,
                      columnSpacing: 18,
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
  // UI Helpers
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

  DropdownMenuItem<String> _dd(String v, String label) {
    return DropdownMenuItem<String>(
      value: v,
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  fontWeight: FontWeight.w800,
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

  Widget _ratingCell(dynamic rating) {
    final parsed = double.tryParse(rating.toString()) ?? 0;
    return Row(
      children: [
        const Icon(Icons.star, size: 18, color: Colors.amber),
        const SizedBox(width: 6),
        Text(
          parsed.toStringAsFixed(1),
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // =========================
  // Actions
  // =========================
  Widget _actionsMenu({
    required Map<String, dynamic> artisan,
    required String id,
    required String status,
    required bool canTakeAction,
    required bool isSuspended,
  }) {
    return PopupMenuButton<_ArtisanAction>(
      tooltip: 'Actions'.tr,
      icon: Icon(Icons.more_horiz, color: AppColors.text),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.border),
      ),
      onSelected: (action) {
        switch (action) {
          case _ArtisanAction.view:
            Get.toNamed('/artisan/details', arguments: artisan);
            break;
          case _ArtisanAction.approve:
            controller.approve(id);
            break;
          case _ArtisanAction.reject:
            controller.reject(id);
            break;
          case _ArtisanAction.suspendToggle:
            controller.setSuspended(id, suspended: !isSuspended);
            break;
        }
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
          value: _ArtisanAction.view,
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.text),
              const SizedBox(width: 10),
              Text('View details'.tr),
            ],
          ),
        ),
        if (canTakeAction) ...[
          PopupMenuItem(
            value: _ArtisanAction.approve,
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.success),
                const SizedBox(width: 10),
                Text('Approve'.tr),
              ],
            ),
          ),
          PopupMenuItem(
            value: _ArtisanAction.reject,
            child: Row(
              children: const [
                Icon(Icons.close, color: Colors.redAccent),
                SizedBox(width: 10),
                Text('Reject', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ] else ...[
          PopupMenuItem(
            value: _ArtisanAction.suspendToggle,
            child: Row(
              children: [
                Icon(
                  isSuspended
                      ? Icons.play_circle_outline
                      : Icons.pause_circle_outline,
                  color: isSuspended ? AppColors.success : Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Text(isSuspended ? 'Unsuspend'.tr : 'Suspend'.tr),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // =========================
  // Filtering + KPI
  // =========================
  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> artisans, {
    required String q,
    required String status,
  }) {
    final qq = q.trim().toLowerCase();
    final st = status.trim().toLowerCase();

    bool statusOk(Map<String, dynamic> a) {
      if (st == 'all') return true;
      final s = _resolveStatus(a).toLowerCase();
      return s == st;
    }

    bool queryOk(Map<String, dynamic> a) {
      if (qq.isEmpty) return true;
      final name = (a['name'] ?? '').toString().toLowerCase();
      final prof = (a['category'] ?? a['profession'] ?? '')
          .toString()
          .toLowerCase();
      return name.contains(qq) || prof.contains(qq);
    }

    return artisans.where((a) => statusOk(a) && queryOk(a)).toList();
  }

  _Kpi _computeKpis(List<Map<String, dynamic>> artisans) {
    int pending = 0, approved = 0, suspended = 0;

    for (final a in artisans) {
      final s = _resolveStatus(a).toLowerCase();
      if (_isPendingStatus(s)) pending++;
      if (s == 'approved' || s == 'active') approved++;
      if (s == 'suspended') suspended++;
    }

    return _Kpi(
      total: artisans.length,
      pending: pending,
      approved: approved,
      suspended: suspended,
    );
  }

  // =========================
  // Status Logic
  // =========================
  Widget _statusChip(String status) {
    final s = status.trim().toLowerCase();
    final color = _statusColor(s);

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

  Color _statusColor(String s) {
    if (s == 'approved' || s == 'active') return AppColors.success;
    if (s == 'pending' || s == 'new' || s == 'review' || s == 'in review')
      return AppColors.warning;
    if (s == 'rejected' || s == 'blocked') return Colors.redAccent;
    if (s == 'suspended' || s == 'inactive') return AppColors.textMuted;
    return AppColors.primary;
  }

  String _resolveStatus(Map<String, dynamic> data) {
    final verificationStatus =
        (data['verificationStatus'] ?? '').toString().trim().toLowerCase();
    final approvedFlag =
        _isTruthy(data['approved']) || _isTruthy(data['isApproved']);
    final activeFlag = _isTruthy(data['active']) || _isTruthy(data['isActive']);
    final verifiedFlag =
        _isTruthy(data['verified']) || _isTruthy(data['isVerified']);
    final rejectedFlag =
        _isTruthy(data['rejected']) || _isTruthy(data['isRejected']);
    final blockedFlag =
        _isTruthy(data['blocked']) || _isTruthy(data['isBlocked']);
    final suspendedFlag = _isTruthy(data['suspended']);

    if (suspendedFlag) return 'Suspended';
    if (blockedFlag) return 'Blocked';
    if (verificationStatus == 'under_review') return 'Under review';
    if (verificationStatus == 'selfie_uploaded') return 'Selfie uploaded';
    if (verificationStatus == 'documents_uploaded') return 'Documents uploaded';
    if (approvedFlag || verifiedFlag) return 'Approved';
    if (activeFlag) return 'Active';
    if (rejectedFlag) return 'Rejected';

    final fromRaw = _statusFromRaw(data['status']);
    return fromRaw ?? 'Pending';
  }

  String? _statusFromRaw(dynamic raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      return trimmed.isEmpty ? null : _normalizeStatus(trimmed);
    }
    if (raw is num) {
      switch (raw.toInt()) {
        case 1:
          return 'Approved';
        case 2:
          return 'Rejected';
        case 0:
          return 'Pending';
      }
    }
    if (raw is bool) return raw ? 'Approved' : 'Pending';
    return null;
  }

  String _normalizeStatus(String status) {
    final trimmed = status.trim();
    final lower = trimmed.toLowerCase();
    switch (lower) {
      case 'approved':
        return 'Approved';
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'under_review':
        return 'Under review';
      case 'selfie_uploaded':
        return 'Selfie uploaded';
      case 'documents_uploaded':
        return 'Documents uploaded';
      case 'suspended':
        return 'Suspended';
      case 'blocked':
        return 'Blocked';
      case 'inactive':
        return 'Inactive';
      default:
        return trimmed.isEmpty ? 'Pending' : trimmed;
    }
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  bool _isPendingStatus(String status) {
    final v = status.trim().toLowerCase();
    return v.isEmpty ||
        v == 'pending' ||
        v == 'review' ||
        v == 'in review' ||
        v == 'new';
  }
}

enum _ArtisanAction { view, approve, reject, suspendToggle }

class _Kpi {
  final int total;
  final int pending;
  final int approved;
  final int suspended;

  _Kpi({
    required this.total,
    required this.pending,
    required this.approved,
    required this.suspended,
  });
}
