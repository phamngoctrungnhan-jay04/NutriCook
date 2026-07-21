import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Nút hành động chính, dùng style từ AppTheme.elevatedButtonTheme (viền cứng
/// đã cấu hình sẵn), bọc thêm bóng đổ cứng (AppShadows.hard) — phong cách
/// Neubrutalism. Hỗ trợ trạng thái loading (spinner thay label).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
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

    final button = Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.buttonRadius,
        boxShadow: onPressed == null ? const [] : AppShadows.hard(theme.brightness),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 0),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );

    if (!fullWidth) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
