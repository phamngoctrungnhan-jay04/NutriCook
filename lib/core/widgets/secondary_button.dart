import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Nút hành động phụ, dùng style từ AppTheme.outlinedButtonTheme (viền cứng
/// đã cấu hình sẵn), bọc thêm bóng đổ cứng (AppShadows.hard) — đồng bộ
/// Neubrutalism với PrimaryButton.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final button = Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.buttonRadius,
        boxShadow: onPressed == null ? const [] : AppShadows.hard(theme.brightness),
      ),
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: primary),
              )
            : Text(label),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
