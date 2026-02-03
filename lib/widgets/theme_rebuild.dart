import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../core/services/theme_controller.dart';

class ThemeRebuild extends StatelessWidget {
  final WidgetBuilder builder;

  const ThemeRebuild({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      // Touch values so Obx rebuilds on theme/text scale changes.
      themeController.themeMode.value;
      themeController.textScale.value;
      return builder(context);
    });
  }
}
