import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppPalette {
  final Color background;
  final Color card;
  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color text;
  final Color textMuted;
  final Color border;
  final Color overlay;

  const AppPalette({
    required this.background,
    required this.card,
    required this.primary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.text,
    required this.textMuted,
    required this.border,
    required this.overlay,
  });
}

class AppColors {
  static const AppPalette dark = AppPalette(
    background: Color(0xFF050816),
    card: Color(0xFF0B1020),
    primary: Color(0xFF2563EB),
    success: Color(0xFF22C55E),
    warning: Color(0xFFFACC15),
    danger: Color(0xFFF43F5E),
    text: Colors.white,
    textMuted: Colors.white70,
    border: Colors.white12,
    overlay: Colors.white10,
  );

  static const AppPalette light = AppPalette(
    background: Color(0xFFF8FAFC),
    card: Color(0xFFFFFFFF),
    primary: Color(0xFF2563EB),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    text: Color(0xFF0F172A),
    textMuted: Color(0xFF475569),
    border: Color(0xFFE2E8F0),
    overlay: Color(0xFFF1F5F9),
  );

  static AppPalette get current => Get.isDarkMode ? dark : light;

  static Color get background => current.background;
  static Color get card => current.card;
  static Color get primary => current.primary;
  static Color get success => current.success;
  static Color get warning => current.warning;
  static Color get danger => current.danger;
  static Color get text => current.text;
  static Color get textMuted => current.textMuted;
  static Color get border => current.border;
  static Color get overlay => current.overlay;
}
