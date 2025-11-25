import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';

class SendNotificationView extends StatefulWidget {
  const SendNotificationView({super.key});

  @override
  State<SendNotificationView> createState() => _SendNotificationViewState();
}

class _SendNotificationViewState extends State<SendNotificationView> {
  String target = 'All';

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Send notification',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create notification'.tr,
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: const Border.fromBorderSide(BorderSide(color: AppColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target audience'.tr, style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: AppSizes.sm),
                Wrap(
                  spacing: AppSizes.sm,
                  children: ['All', 'Customers', 'Artisans']
                      .map(
                        (item) => ChoiceChip(
                          label: Text(item.tr),
                          selected: target == item,
                          onSelected: (_) => setState(() => target = item),
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.card,
                          labelStyle: TextStyle(
                            color: target == item ? Colors.white : AppColors.textMuted,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(labelText: 'Title'.tr),
                ),
                const SizedBox(height: AppSizes.md),
                TextField(
                  style: const TextStyle(color: AppColors.text),
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Message'.tr,
                    hintText: 'Type notification message'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                PrimaryButton(
                  expand: true,
                  label: 'Send notification'.tr,
                  icon: Icons.send,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
