import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/core/services/formate_date.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
import '../controllers/artisan_details_controller.dart';

class ArtisanDetailsView extends StatelessWidget {
  const ArtisanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final id = (args?['_id'] ?? args?['id'] ?? '').toString();
    final isMobile = Responsive.isMobile(context);
    final controller = Get.put(ArtisanDetailsController());
    if (id.isNotEmpty) controller.load(id);

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
              style: const TextStyle(color: AppColors.textMuted),
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
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Artisan details'.tr,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: AppSizes.xs),
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
                                    (data['profession'] ??
                                            data['category'] ??
                                            '')
                                        .toString(),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                status.tr,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.md),
                          Wrap(
                            spacing: AppSizes.md,
                            runSpacing: AppSizes.md,
                            children: [
                              _stat(
                                'Completed requests label'.tr,
                                (stats['completed'] ?? '').toString(),
                              ),
                              _stat(
                                'Active jobs'.tr,
                                (stats['active'] ?? '').toString(),
                              ),
                              _stat(
                                'Average ticket'.tr,
                                (stats['avgTicket'] ?? '').toString(),
                              ),
                              _stat(
                                'Member since'.tr,
                                (formatDateString(
                                  data['createdAt'],
                                )).toString(),
                              ),
                            ],
                          ),
                          if (canTakeAction) ...[
                            const SizedBox(height: AppSizes.md),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => controller.approve(id),
                                  child: Text('Approve'.tr),
                                ),
                                const SizedBox(width: AppSizes.sm),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    foregroundColor: AppColors.text,
                                  ),
                                  onPressed: () => controller.reject(id),
                                  child: Text('Reject'.tr),
                                ),
                              ],
                            ),
                          ],
                          if (!canTakeAction) ...[
                            const SizedBox(height: AppSizes.md),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.border),
                                foregroundColor: AppColors.text,
                              ),
                              onPressed: () => controller.setSuspended(id, suspended: !isSuspended),
                              child: Text(isSuspended ? 'Unsuspend'.tr : 'Suspend'.tr),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!isMobile) const SizedBox(width: AppSizes.md),
                  if (!isMobile)
                    Container(
                      width: 240,
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
                          Text(
                            'Documents'.tr,
                            style: const TextStyle(color: AppColors.text),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          ...docs.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.xs,
                              ),
                              child: Text(
                                d.toString(),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
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
                      'Ratings'.tr,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      (stats['rating'] ?? '').toString(),
                      style: const TextStyle(color: AppColors.text),
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

  String _resolveStatus(Map<String, dynamic> data) {
    final approvedFlag = _isTruthy(data['approved']) || _isTruthy(data['isApproved']);
    final activeFlag = _isTruthy(data['active']) || _isTruthy(data['isActive']);
    final verifiedFlag = _isTruthy(data['verified']) || _isTruthy(data['isVerified']);
    final rejectedFlag = _isTruthy(data['rejected']) || _isTruthy(data['isRejected']);
    final blockedFlag = _isTruthy(data['blocked']) || _isTruthy(data['isBlocked']);
    final suspendedFlag = _isTruthy(data['suspended']);

    if (suspendedFlag) {
      return 'Suspended';
    }
    if (blockedFlag) {
      return 'Blocked';
    }
    if (approvedFlag || verifiedFlag) {
      return 'Approved';
    }
    if (activeFlag) {
      return 'Active';
    }
    if (rejectedFlag) {
      return 'Rejected';
    }

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
    if (raw is bool) {
      return raw ? 'Approved' : 'Pending';
    }
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
