import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../data/providers/mock_data.dart';
import '../../../layout/admin_layout.dart';

class ReviewsListView extends StatefulWidget {
  const ReviewsListView({super.key});

  @override
  State<ReviewsListView> createState() => _ReviewsListViewState();
}

class _ReviewsListViewState extends State<ReviewsListView> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final reviews = filter == 'All'
        ? MockData.reviews
        : MockData.reviews.where((r) => r.rating >= 4).toList();

    return AdminLayout(
      title: 'Reviews',
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
              DropdownButton<String>(
                value: filter,
                dropdownColor: AppColors.card,
                items: [
                  DropdownMenuItem(value: 'All', child: Text('All ratings'.tr)),
                  DropdownMenuItem(value: 'Positive', child: Text('4 stars and above'.tr)),
                ],
                onChanged: (value) => setState(() => filter = value ?? 'All'),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...reviews.map(
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
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${review.date.day}/${review.date.month}/${review.date.year}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    review.text,
                    style: const TextStyle(color: AppColors.text),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${review.customer} → ${review.artisan}',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
