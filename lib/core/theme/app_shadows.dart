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

  /// Bóng đổ "cứng" (offset thuần, không mờ, không tràn) — phong cách
  /// Neubrutalism, dùng cho Button/TextField/SocialLoginButton theo yêu cầu
  /// bổ sung (xem UI_UX_GUIDELINES.md mục Button Design — Neubrutalism
  /// Variant). Dark Mode dùng màu trắng để vẫn nổi trên nền tối.
  static List<BoxShadow> hard(Brightness brightness) {
    final color = brightness == Brightness.dark ? Colors.white : Colors.black;
    return [BoxShadow(color: color, offset: const Offset(4, 4))];
  }
}
