import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/shimmer_widgets.dart';
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
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
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
                child: Text('No data'.tr, style: const TextStyle(color: AppColors.textMuted)),
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
                        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
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
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (review['text'] ?? review['comment'] ?? '').toString(),
                            style: const TextStyle(color: AppColors.text),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${review['customerId']?['name'] ??  ''} • ${review['artisanId']?['name'] ?? ''}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
}


