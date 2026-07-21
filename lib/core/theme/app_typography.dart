import 'package:flutter/material.dart';

/// Type scale theo UI_UX_GUIDELINES.md mục Typography, dùng font hệ thống mặc định
/// (Roboto/San Francisco theo nền tảng) — không nhúng custom font cho MVP.
class AppTypography {
  const AppTypography._();

  static TextTheme textTheme({
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return TextTheme(
      // Display / Headline — tên món ăn ở Detail Screen, tiêu đề màn hình lớn.
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: textPrimary,
      ),
      // Title — tiêu đề section, tên món trong Card.
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: textPrimary,
      ),
      // Body — nội dung chính.
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: textPrimary,
      ),
      // Button text.
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: textPrimary,
      ),
      // Label / Caption.
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: textSecondary,
      ),
    );
  }
}
