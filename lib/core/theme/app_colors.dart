import 'package:flutter/material.dart';

/// Bảng màu chuẩn hóa của NutriCook, theo UI_UX_GUIDELINES.md mục Color Palette
/// — phong cách Neubrutalism (xanh dương nhạt + be + viền/bóng đen), lấy trực
/// tiếp từ CSS tham khảo: `--bg-color: beige`, nền `lightblue`, accent
/// `--input-focus: #2d8cf0`, viền/bóng `--main-color: black`.
class AppColors {
  const AppColors._();

  // Light — khớp đúng bảng màu CSS tham khảo.
  static const Color lightPrimary = Color(0xFF2D8CF0);
  static const Color lightSecondary = Color(0xFF4C9A6A);
  static const Color lightBackground = Color(0xFFADD8E6);
  static const Color lightSurface = Color(0xFFF5F5DC);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightTextPrimary = Color(0xFF323232);
  static const Color lightTextSecondary = Color(0xFF666666);

  /// Đồng thời là màu viền/bóng cứng (Hard Border/Shadow) — bản CSS tham khảo
  /// dùng chung 1 biến `--main-color: black` cho cả viền lẫn bóng lẫn divider.
  static const Color lightDivider = Color(0xFF000000);

  // Dark — bản CSS tham khảo chỉ có Light Mode, các giá trị dưới đây là suy
  // diễn tương đồng: giữ đúng tinh thần "nền xanh/be, viền đen" nhưng đảo tông
  // cho phù hợp nền tối (viền/bóng đổi sang trắng để vẫn nổi rõ).
  static const Color darkPrimary = Color(0xFF5B9FF2);
  static const Color darkSecondary = Color(0xFF6FBF8C);
  static const Color darkBackground = Color(0xFF14212B);
  static const Color darkSurface = Color(0xFF2B2920);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkTextPrimary = Color(0xFFF2F2F2);
  static const Color darkTextSecondary = Color(0xFFA8A8A8);
  static const Color darkDivider = Color(0xFFFFFFFF);
}
