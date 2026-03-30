import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usta_admin_panal/widgets/modules/categories/views/category_icon.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/responsive.dart';
import '../../../../layout/admin_layout.dart';
import '../../../shimmer_widgets.dart';
import '../controllers/categories_controller.dart';

class CategoriesListView extends StatefulWidget {
  const CategoriesListView({super.key});

  @override
  State<CategoriesListView> createState() => _CategoriesListViewState();
}

class _CategoriesListViewState extends State<CategoriesListView> {
  late final CategoriesController controller;
  final RxString search = ''.obs;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CategoriesController());
  }

  int _columnsForWidth(double w) {
    if (w >= 1200) return 4;
    if (w >= 900) return 3;
    if (w >= 650) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return AdminLayout(
      title: 'Service categories'.tr,
      actions: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =========================
          // HEADER
          // =========================
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 760;

              final titleBlock = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service categories'.tr,
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Manage services shown to customers'.tr,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );

              final refreshButton = OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text,
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onPressed: controller.loadCategories,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Refresh'.tr),
              );

              final newButton = ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
                onPressed: () => Get.toNamed('/category/add'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text('New category'.tr),
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleBlock,
                    const SizedBox(height: AppSizes.sm),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: [refreshButton, newButton],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleBlock),
                  refreshButton,
                  const SizedBox(width: AppSizes.sm),
                  newButton,
                ],
              );
            },
          ),

          const SizedBox(height: AppSizes.md),

          // =========================
          // SEARCH
          // =========================
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: AppColors.textMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (v) => search.value = v.trim(),
                    style: TextStyle(color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Search categories...'.tr,
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Obx(() {
                  if (search.value.isEmpty) return const SizedBox.shrink();
                  return IconButton(
                    tooltip: 'Clear'.tr,
                    onPressed: () => search.value = '',
                    icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // =========================
          // BODY
          // =========================
          Obx(() {
            if (controller.loading.value) {
              return Column(
                children: const [
                  CardLoading(lines: 8),
                  SizedBox(height: AppSizes.sm),
                  CardLoading(lines: 8),
                ],
              );
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

            if (controller.categories.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'No data'.tr,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }

            // filter local
            final q = search.value.toLowerCase();
            final list = controller.categories.where((c) {
              final name = (c['name'] ?? '').toString().toLowerCase();
              if (q.isEmpty) return true;
              return name.contains(q);
            }).toList();

            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'No results'.tr,
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, c) {
                final cols = _columnsForWidth(c.maxWidth);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: AppSizes.md,
                    mainAxisSpacing: AppSizes.md,
                    childAspectRatio: isMobile ? 2.9 : 2.35,
                  ),
                  itemCount: list.length,
                  itemBuilder: (_, i) => _CategoryCard(
                    category: list[i] as Map<String, dynamic>,
                    controller: controller,
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final CategoriesController controller;

  const _CategoryCard({required this.category, required this.controller});

  @override
  Widget build(BuildContext context) {
    final name = (category['name'] ?? '').toString().trim();
    final iconText = getCategoryIcon(name);
    final id = (category['_id'] ?? category['id'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.fromBorderSide(BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 8),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Row(
        children: [
          // icon block
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.22)),
            ),
            child: Center(
              child: Text(
                iconText,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),

          // texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Icon preview'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 10),

                // actions
                Row(
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () =>
                          _openEditDialog(context, controller, category),
                      child: Text('Edit'.tr),
                    ),
                    const SizedBox(width: AppSizes.xs),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: id.isEmpty
                          ? null
                          : () => _confirmDelete(
                              context,
                              onConfirm: () => controller.removeCategory(id),
                            ),
                      child: Text('Delete'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // نفس منطقك
  String getCategoryIcon(dynamic name) {
    if (name == null) return "•";
    final String title = name.toString().trim().toLowerCase();
    if (title.isEmpty) return "•";

    for (final key in categoryIcons.keys) {
      if (title.contains(key)) {
        return categoryIcons[key]!;
      }
    }
    return title[0].toUpperCase();
  }

  void _openEditDialog(
    BuildContext context,
    CategoriesController controller,
    Map<String, dynamic> category,
  ) {
    final id = (category['_id'] ?? category['id'] ?? '').toString();
    if (id.isEmpty) return;

    final nameController = TextEditingController(
      text: (category['name'] ?? '').toString(),
    );

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Edit category'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            labelText: 'Category name'.tr,
            labelStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.8)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.updateCategory(id, name: nameController.text.trim());
            },
            child: Text(
              'Save'.tr,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, {required VoidCallback onConfirm}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Delete category'.tr,
          style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w900),
        ),
        content: Text(
          'This action cannot be undone.'.tr,
          style: TextStyle(color: AppColors.textMuted, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel'.tr,
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: Text(
              'Delete'.tr,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
