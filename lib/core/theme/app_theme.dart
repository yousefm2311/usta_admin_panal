import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData get dark => _buildTheme(AppColors.dark, Brightness.dark);

  static ThemeData get light => _buildTheme(AppColors.light, Brightness.light);

  static ThemeData _buildTheme(AppPalette palette, Brightness brightness) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      primaryColor: palette.primary,
      cardColor: palette.card,
      dividerColor: palette.border,
      colorScheme: base.colorScheme.copyWith(
        brightness: brightness,
        primary: palette.primary,
        secondary: palette.primary,
        surface: palette.card,
        background: palette.background,
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(
          brightness == Brightness.dark ? 0.24 : 0.06,
        ),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: palette.border),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        elevation: 0,
        foregroundColor: palette.text,
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: palette.textMuted),
        hintStyle: TextStyle(color: palette.textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
          borderSide: BorderSide(color: palette.primary),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.inputRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.text,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          side: BorderSide(color: palette.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          side: BorderSide(color: palette.border),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: palette.overlay,
        selectedColor: palette.primary.withOpacity(0.12),
        side: BorderSide(color: palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(color: palette.text, fontWeight: FontWeight.w600),
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(palette.overlay),
        dataRowColor: WidgetStatePropertyAll(palette.card),
        dividerThickness: 0.4,
        headingTextStyle: TextStyle(
          color: palette.textMuted,
          fontWeight: FontWeight.w800,
        ),
        dataTextStyle: TextStyle(
          color: palette.text,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Cairo',
        bodyColor: palette.text,
        displayColor: palette.text,
      ),
    );
  }
}
