import 'package:flutter/material.dart';

/// Shadow theo elevation, UI_UX_GUIDELINES.md mục Shadow.
///
/// Dark Mode gần như tắt shadow (thay bằng chênh lệch màu Surface) vì shadow đen
/// trên nền tối gần như vô hình và lãng phí hiệu năng.
class AppShadows {
  const AppShadows._();

  static List<BoxShadow> card(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> dialog(Brightness brightness) {
    if (brightness == Brightness.dark) return const [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}
