import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// ThemeData hoàn chỉnh cho NutriCook. Dùng `AppTheme.light`/`AppTheme.dark` trong
/// MaterialApp cùng `themeMode: ThemeMode.system` (xem UI_UX_GUIDELINES.md mục Dark
/// Mode Strategy) — không cung cấp công tắc chuyển theme thủ công cho MVP.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final primary = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final secondary = isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
    final background = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final error = isDark ? AppColors.darkError : AppColors.lightError;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    // `divider` đồng thời là màu viền/bóng cứng (Neubrutalism) — đen ở Light,
    // trắng ở Dark, dùng thống nhất cho Button/TextField/Card/Dialog/Chip.
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    final textTheme = AppTypography.textTheme(
      textPrimary: textPrimary,
      textSecondary: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerColor: divider,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
          side: BorderSide(color: divider, width: 2),
        ),
      ),
      // Primary Button: nền be (Surface) + chữ đen, khớp đúng `.button-confirm`
      // của CSS tham khảo (nút không tô màu accent, chỉ viền/chữ đen).
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
            side: BorderSide(color: divider, width: 2),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: divider, width: 2),
          minimumSize: const Size.fromHeight(48),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: BorderSide(color: divider, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: BorderSide(color: divider, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: BorderSide(color: error, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.all(textTheme.labelMedium),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialogRadius,
          side: BorderSide(color: divider, width: 2),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightTextPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.25),
        labelStyle: textTheme.labelMedium,
        side: BorderSide(color: divider, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
      ),
    );
  }
}
