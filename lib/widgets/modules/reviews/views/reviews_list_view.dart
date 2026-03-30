import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/reviews_controller.dart';

class ReviewsListView extends StatelessWidget {
  const ReviewsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReviewsController());
    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Reviews'.tr,
                style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Obx(
                () => DropdownButton<String>(
                  value: controller.filter.value,
                  dropdownColor: AppColors.card,
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All ratings'.tr)),
                    DropdownMenuItem(value: 'Positive', child: Text('4 stars and above'.tr)),
                  ],
                  onChanged: (value) => controller.filter.value = value ?? 'All',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Obx(() {
            if (controller.loading.value) {
              return const ListLoading();
            }
            if (controller.error.value != null) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(controller.error.value!, style: const TextStyle(color: Colors.redAccent)),
              );
            }
            final reviews = controller.filtered;
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
              );
            }
            return Column(
              children: reviews
                  .map(
                    
                    (review) => Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.sm),
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                        border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => Icon(
                                    i < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(review['date'] ?? review['createdAt']),
                                style:  TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                              const SizedBox(width: AppSizes.xs),
                              IconButton(
                                tooltip: 'Delete'.tr,
                                onPressed: () => _confirmDelete(context, controller, review),
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (review['text'] ?? review['comment'] ?? '').toString(),
                            style:  TextStyle(color: AppColors.text),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${review['customerId']?['name'] ??  ''} • ${review['artisanId']?['name'] ?? ''}',
                            style:  TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
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

  void _confirmDelete(BuildContext context, ReviewsController controller, Map<String, dynamic> review) {
    final id = (review['_id'] ?? review['id'] ?? '').toString();
    if (id.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete'.tr, style:  TextStyle(color: AppColors.text)),
        content: Text('Delete this review?'.tr, style:  TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'.tr, style:  TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.deleteReview(id);
            },
            child: Text('Delete'.tr, style: const TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}


