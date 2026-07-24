import 'package:flutter/material.dart';

import '../theme/app_shadows.dart';

/// Nút đăng nhập mạng xã hội dạng tròn, viền + bóng cứng (Neubrutalism).
/// Dùng chữ cái làm biểu tượng (ví dụ 'G' cho Google) thay vì logo SVG, để
/// không phải thêm package/asset thương hiệu mới cho MVP.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: AppShadows.hard(theme.brightness),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
