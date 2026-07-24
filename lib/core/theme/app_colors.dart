import 'package:flutter/material.dart';

/// Bảng màu chuẩn hóa của NutriCook, theo UI_UX_GUIDELINES.md mục Color Palette.
class AppColors {
  const AppColors._();

  // Light
  static const Color lightPrimary = Color(0xFFE8622C);
  static const Color lightSecondary = Color(0xFF4C9A6A);
  static const Color lightBackground = Color(0xFFFAFAF7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightTextPrimary = Color(0xFF1B1B1B);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightDivider = Color(0xFFE4E4E0);

  // Dark
  // darkPrimary/darkSecondary không có mã hex cố định trong UI_UX_GUIDELINES.md
  // (chỉ mô tả định tính "giảm độ chói"/"sáng hơn để nổi trên nền tối") — giá trị dưới
  // đây là suy diễn cụ thể theo đúng tinh thần mô tả đó.
  static const Color darkPrimary = Color(0xFFF2895E);
  static const Color darkSecondary = Color(0xFF6FBF8C);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkDivider = Color(0xFF2C2C2C);
}
