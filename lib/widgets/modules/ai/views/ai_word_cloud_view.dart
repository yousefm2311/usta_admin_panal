import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/ai_word_cloud_controller.dart';

class AIWordCloudView extends StatelessWidget {
  const AIWordCloudView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIWordCloudController());

    return AdminLayout(
      title: '',
      child: Obx(() {
        if (controller.loading.value) {
          return const ListLoading(rows: 4, itemHeight: 20, padding: EdgeInsets.zero);
        }
        if (controller.wordCloud.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Text('No data'.tr, style:  TextStyle(color: AppColors.textMuted)),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word cloud'.tr,
              style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: AppSizes.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.lg),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
              ),
              child: Wrap(
                spacing: AppSizes.sm,
                runSpacing: AppSizes.sm,
                children: controller.wordCloud
                    .map(
                      (w) => _Word(
                        w['word']?.toString() ?? '',
                        14 + ((w['count'] ?? 1) as num).toDouble(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _Word extends StatelessWidget {
  final String text;
  final double size;

  const _Word(this.text, this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: Colors.primaries[text.hashCode % Colors.primaries.length],
      ),
    );
  }
}
