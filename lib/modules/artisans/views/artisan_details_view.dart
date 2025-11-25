import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/responsive.dart';
import '../../../data/providers/mock_data.dart';
import '../../../data/models/artisan_model.dart';
import '../../../layout/admin_layout.dart';

class ArtisanDetailsView extends StatelessWidget {
  const ArtisanDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ArtisanModel artisan = MockData.artisans.first;
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: 'Artisan details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              children: [
                _profileCard(artisan),
                const SizedBox(height: AppSizes.md),
                _statsCard(artisan),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _profileCard(artisan)),
                const SizedBox(width: AppSizes.md),
                Expanded(child: _statsCard(artisan)),
              ],
            ),
          const SizedBox(height: AppSizes.lg),
          if (isMobile)
            Column(
              children: [
                _documentsCard(artisan),
                const SizedBox(height: AppSizes.md),
                _ratingCard(artisan),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _documentsCard(artisan)),
                const SizedBox(width: AppSizes.md),
                Expanded(child: _ratingCard(artisan)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _profileCard(ArtisanModel art) {
    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primary.withOpacity(0.18),
            child: const Icon(Icons.engineering, color: AppColors.text, size: 30),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  art.name,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(art.category, style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(art.rating.toStringAsFixed(1), style: const TextStyle(color: AppColors.text)),
                    const SizedBox(width: AppSizes.sm),
                    _statusChip(art.status),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.check),
                label: Text('Approve'.tr),
              ),
              const SizedBox(height: AppSizes.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: const BorderSide(color: AppColors.border),
                ),
                onPressed: () {},
                child: Text('Reject'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsCard(ArtisanModel art) {
    return _card(
      child: Wrap(
        spacing: AppSizes.md,
        runSpacing: AppSizes.md,
        children: [
          _miniStat('Completed requests label'.tr, art.completed.toString()),
          _miniStat('Active jobs'.tr, '6'),
          _miniStat('Average ticket'.tr, 'EG 420'),
          _miniStat('Member since'.tr, 'Feb 2024'),
        ],
      ),
    );
  }

  Widget _documentsCard(ArtisanModel art) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Documents'.tr),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: art.documents
                .map<Widget>(
                  (doc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file, color: AppColors.textMuted, size: 18),
                        const SizedBox(width: 8),
                        Text(doc, style: const TextStyle(color: AppColors.text)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _ratingCard(ArtisanModel art) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Ratings'.tr),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Text('4.8', style: TextStyle(color: AppColors.text, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(width: AppSizes.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Based on 142 reviews'.tr, style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 4),
                  Text('Top performer in Dubai'.tr, style: const TextStyle(color: AppColors.text)),
                ],
              )
            ],
          ),
          const SizedBox(height: AppSizes.md),
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text('${5 - i} ${'stars'.tr}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (5 - i) / 5,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String title, String value) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.overlay,
        borderRadius: BorderRadius.circular(AppSizes.inputRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'Approved':
        color = AppColors.success;
        break;
      case 'Pending':
        color = AppColors.warning;
        break;
      case 'Rejected':
        color = AppColors.danger;
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
        status.tr,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
