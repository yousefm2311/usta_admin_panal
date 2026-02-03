import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const _themeKey = 'app_theme_mode';
  static const _textScaleKey = 'app_text_scale';

  final GetStorage _box = GetStorage();

  final themeMode = ThemeMode.dark.obs;
  final textScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
    _loadTextScale();
  }

  void toggleTheme() {
    final next = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setTheme(next);
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _box.write(_themeKey, mode.name);
    Get.forceAppUpdate();
  }

  void setTextScale(double scale) {
    final normalized = scale.clamp(0.85, 1.35).toDouble();
    textScale.value = normalized;
    _box.write(_textScaleKey, normalized);
    Get.forceAppUpdate();
  }

  void _loadTheme() {
    final stored = _box.read<String>(_themeKey);
    final mode = _parseThemeMode(stored) ?? ThemeMode.dark;
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  void _loadTextScale() {
    final stored = _box.read(_textScaleKey);
    if (stored is num) {
      textScale.value = stored.toDouble().clamp(0.85, 1.35).toDouble();
    }
  }

  ThemeMode? _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
    }
    return null;
  }
}
