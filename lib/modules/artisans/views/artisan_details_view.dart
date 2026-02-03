import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../core/utils/notify.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/artisan_details_controller.dart';

class ArtisanDetailsView extends StatefulWidget {
  const ArtisanDetailsView({super.key});

  @override
  State<ArtisanDetailsView> createState() => _ArtisanDetailsViewState();
}

class _ArtisanDetailsViewState extends State<ArtisanDetailsView> {
  late final ArtisanDetailsController controller;

  String artisanId = '';
  bool loadedOnce = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ArtisanDetailsController());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loadedOnce) return;

    final args = Get.arguments as Map<String, dynamic>?;
    artisanId = (args?['_id'] ?? args?['id'] ?? '').toString();

    if (artisanId.isNotEmpty) {
      controller.load(artisanId);
      loadedOnce = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const CardLoading(height: 300, lines: 10);
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

        final data = controller.artisan.value;
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text(
              'No data'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          );
        }

        final docs = (data['documents'] ?? []) as List<dynamic>;
        final statsRaw = data['stats'] ?? {};
        final stats = statsRaw is Map<String, dynamic>
            ? statsRaw
            : statsRaw is Map
            ? Map<String, dynamic>.from(statsRaw)
            : <String, dynamic>{};

        final status = _resolveStatus(data);
        final canTakeAction = _isPendingStatus(status);
        final isSuspended = _isTruthy(data['suspended']);

        final name = (data['name'] ?? '').toString();
        final profession = (data['profession'] ?? data['category'] ?? '')
            .toString();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =========================
              // TITLE
              // =========================
              Text(
                'Artisan details'.tr,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: AppSizes.sm),

              // =========================
              // TOP ROW (Profile + Docs)
              // =========================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.14,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isEmpty ? '-' : name,
                                      style: TextStyle(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      profession,
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSizes.sm),
                              _statusChip(status),
                              const SizedBox(width: 8),
                              _actionsMenu(
                                canTakeAction: canTakeAction,
                                isSuspended: isSuspended,
                                onApprove: () => controller.approve(artisanId),
                                onReject: () => controller.reject(artisanId),
                                onSuspendToggle: () => controller.setSuspended(
                                  artisanId,
                                  suspended: !isSuspended,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSizes.md),

                          Wrap(
                            spacing: AppSizes.md,
                            runSpacing: AppSizes.md,
                            children: [
                              _miniStat(
                                'Completed requests label'.tr,
                                _formatStatValue(stats['completed']),
                                icon: Icons.check_circle_outline,
                                color: AppColors.success,
                              ),
                              _miniStat(
                                'Active jobs'.tr,
                                _formatStatValue(stats['active']),
                                icon: Icons.work_outline,
                                color: AppColors.warning,
                              ),
                              _miniStat(
                                'Average ticket'.tr,
                                _formatStatValue(stats['avgTicket']),
                                icon: Icons.payments_outlined,
                                color: Colors.tealAccent,
                              ),
                              _miniStat(
                                'Member since'.tr,
                                (formatDateString(
                                  data['createdAt'],
                                )).toString(),
                                icon: Icons.calendar_today_outlined,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!isMobile) const SizedBox(width: AppSizes.md),

                  if (!isMobile)
                    SizedBox(width: 280, child: _documentsCard(docs)),
                ],
              ),

              const SizedBox(height: AppSizes.md),

              // Mobile documents
              if (isMobile) ...[
                _documentsCard(docs),
                const SizedBox(height: AppSizes.md),
              ],

              // =========================
              // DETAILS CARD
              // =========================
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Details'.tr,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        _pill(icon: Icons.info_outline, text: 'Core'.tr),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sm),
                    _infoRow(
                      'Email address'.tr,
                      (data['email'] ?? '').toString(),
                    ),
                    _infoRow('Phone'.tr, (data['phone'] ?? '').toString()),
                    _infoRow('Address'.tr, (data['address'] ?? '').toString()),
                    _infoRow('Status'.tr, status.tr),
                    _infoRow('Services'.tr, _formatServices(data['services'])),
                    _infoRow(
                      'Online'.tr,
                      (data['isOnline'] == true ? 'Online'.tr : 'Offline'.tr),
                    ),
                    _infoRow(
                      'Profile completion'.tr,
                      _formatStatValue(data['profileCompletion']),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // =========================
              // CUSTOMERS PREVIEW
              // =========================
              _customersSection(data['customersPreview']),

              const SizedBox(height: AppSizes.md),

              // =========================
              // FULL DETAILS (New UI)
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
                    _detailsSections(data),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.md),

              // =========================
              // RATINGS
              // =========================
              _card(
                child: Row(
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.star, color: Colors.amber),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ratings'.tr,
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatStatValue(stats['rating']),
                          style: TextStyle(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // =========================================================
  // UI building blocks
  // =========================================================

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

  Widget _miniStat(
    String label,
    String value, {
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionsMenu({
    required bool canTakeAction,
    required bool isSuspended,
    required VoidCallback onApprove,
    required VoidCallback onReject,
    required VoidCallback onSuspendToggle,
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
          case _ArtisanAction.approve:
            onApprove();
            break;
          case _ArtisanAction.reject:
            onReject();
            break;
          case _ArtisanAction.suspendToggle:
            onSuspendToggle();
            break;
        }
      },
      itemBuilder: (ctx) => [
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

  Widget _documentsCard(List<dynamic> docs) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Documents'.tr,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _pill(icon: Icons.folder_open, text: '${docs.length}'),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          if (docs.isEmpty)
            Text('No data'.tr, style: TextStyle(color: AppColors.textMuted))
          else
            ...docs.take(8).map((d) {
              final s = d.toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy'.tr,
                      onPressed: () => _copyText(s),
                      icon: Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }),
          if (docs.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '+ ${docs.length - 8} more'.tr,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _customersSection(dynamic customersRaw) {
    final customers = customersRaw is List
        ? customersRaw.cast<dynamic>()
        : <dynamic>[];
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customers'.tr,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          if (customers.isEmpty)
            Text('No data'.tr, style: TextStyle(color: AppColors.textMuted))
          else
            ...customers.map((raw) {
              final c = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
              final name = (c['name'] ?? '').toString();
              final phone = (c['phone'] ?? '').toString();
              final email = (c['email'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      child: Icon(
                        Icons.person,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? '-' : name,
                            style: TextStyle(
                              color: AppColors.text,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (phone.isNotEmpty)
                            Text(
                              phone,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (email.isNotEmpty)
                            Text(
                              email,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (phone.isNotEmpty)
                      IconButton(
                        tooltip: 'Copy'.tr,
                        onPressed: () => _copyText(phone),
                        icon: Icon(
                          Icons.copy,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
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
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (canCopy)
            IconButton(
              tooltip: 'Copy'.tr,
              onPressed: () => _copyText(value),
              icon: Icon(Icons.copy, size: 16, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }

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
    if (_isPendingStatus(s)) return AppColors.warning;
    if (s == 'rejected' || s == 'blocked') return Colors.redAccent;
    if (s == 'suspended' || s == 'inactive') return AppColors.textMuted;
    return AppColors.primary;
  }

  String _formatServices(dynamic services) {
    if (services is List) {
      final names = services
          .map((s) => s is Map<String, dynamic> ? (s['name'] ?? '') : s)
          .where((s) => s != null && s.toString().isNotEmpty)
          .map((s) => s.toString())
          .toList();
      return names.isEmpty ? '-' : names.join(', ');
    }
    return services?.toString() ?? '-';
  }

  // =========================================================
  // Full details (structured)
  // =========================================================
  Widget _detailsSections(Map<String, dynamic> data) {
    final preferredOrder = <String>[
      'name',
      'phone',
      'email',
      'status',
      'approved',
      'active',
      'verified',
      'blocked',
      'suspended',
      'profession',
      'category',
      'services',
      'address',
      'location',
      'createdAt',
      'updatedAt',
      'stats',
      'documents',
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
        final title = _prettyKey(e.key);
        final value = e.value;
        return _sectionCard(
          title: title,
          meta: _valueMeta(value),
          content: _renderAnyValue(title, value),
        );
      }).toList(),
    );
  }

  Widget _sectionCard({
    required String title,
    required String meta,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
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

  Widget _renderAnyValue(String label, dynamic value) {
    if (value == null) return _valueBox(label, '-');

    if (value is Map) {
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

    final txt = _formatSimple(value);
    return _valueBox(label, txt);
  }

  Widget _kvGrid(List<(String k, String v)> items) {
    if (items.isEmpty) return _valueBox(''.tr, '-');

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
    final cleaned = key.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) return '-';
    return cleaned[0].toUpperCase() + cleaned.substring(1);
  }

  // =========================================================
  // Existing helpers (kept)
  // =========================================================
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

  String _formatSimple(dynamic value) {
    if (value == null) return '-';
    if (value is String) return value.isEmpty ? '-' : value;
    if (value is num || value is bool) return value.toString();
    return value.toString();
  }

  bool _canCopyValue(String label, String value) {
    if (value.isEmpty || value == '-') return false;
    final lower = label.toLowerCase();
    if (lower.contains('email') ||
        lower.contains('phone') ||
        lower.contains('token'))
      return true;
    if (label.contains('ايميل') ||
        label.contains('بريد') ||
        label.contains('هاتف') ||
        label.contains('موبايل') ||
        label.contains('توكن'))
      return true;
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

  String _formatStatValue(dynamic value) {
    if (value == null) return '0';
    final text = value.toString();
    if (text.isEmpty) return '0';
    final parsed = double.tryParse(text);
    if (parsed == null) return text;
    if (parsed % 1 == 0) return parsed.toInt().toString();
    return parsed.toStringAsFixed(1);
  }

  String _resolveStatus(Map<String, dynamic> data) {
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
    final value = status.trim().toLowerCase();
    return value.isEmpty ||
        value == 'pending' ||
        value == 'review' ||
        value == 'in review' ||
        value == 'new';
  }
}

enum _ArtisanAction { approve, reject, suspendToggle }
