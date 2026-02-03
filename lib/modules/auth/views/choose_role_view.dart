import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';

class ChooseRoleView extends StatelessWidget {
  const ChooseRoleView({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = ['Admin', 'Support', 'Finance'];
    return AdminLayout(
      title: 'Choose Role'.tr,
      child: Center(
        child: Wrap(
          spacing: AppSizes.md,
          runSpacing: AppSizes.md,
          alignment: WrapAlignment.center,
          children: roles
              .map(
                (r) => InkWell(
                  onTap: () => Get.offAllNamed('/dashboard'),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(AppSizes.lg),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                      border:  Border.fromBorderSide(BorderSide(color: AppColors.border)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         Icon(Icons.shield, color: AppColors.primary, size: 32),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          r.tr,
                          style:  TextStyle(color: AppColors.text, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('Proceed as $r'.tr, style:  TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
