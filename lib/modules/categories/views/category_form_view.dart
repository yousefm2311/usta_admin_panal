import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/modules/categories/controllers/categories_controller.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../layout/admin_layout.dart';
import '../../../widgets/primary_button.dart';

class CategoryFormView extends StatefulWidget {
  const CategoryFormView({super.key});

  @override
  State<CategoryFormView> createState() => _CategoryFormViewState();
}

class _CategoryFormViewState extends State<CategoryFormView> {
  String selectedIcon = 'cleaning';
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoriesController>();
    return AdminLayout(
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a new category'.tr,
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
              children: [
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: AppColors.text),
                  decoration: InputDecoration(
                    labelText: 'Category name'.tr,
                    hintText: 'Cleaning'.tr,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Icon picker'.tr,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    DropdownButton<String>(
                      value: selectedIcon,
                      dropdownColor: AppColors.card,
                      items: [
                        DropdownMenuItem(value: 'cleaning', child: Text('Cleaning'.tr)),
                        DropdownMenuItem(value: 'plumbing', child: Text('Plumbing'.tr)),
                        DropdownMenuItem(value: 'electric', child: Text('Electrician'.tr)),
                        DropdownMenuItem(value: 'painting', child: Text('Painting'.tr)),
                        DropdownMenuItem(value: 'hvac', child: Text('HVAC'.tr)),
                      ],
                      onChanged: (value) => setState(() => selectedIcon = value ?? 'cleaning'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Obx(() {
                  final saving = controller.saving.value;
                  return PrimaryButton(
                    expand: true,
                    label: saving ? 'Loading'.tr : 'Save category'.tr,
                    icon: Icons.save_outlined,
                    onPressed: saving
                        ? null
                        : () {
                            controller.addCategory(
                              name: _nameController.text.trim(),
                              icon: selectedIcon,
                            );
                          },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
