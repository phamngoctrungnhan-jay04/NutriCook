import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'secondary_button.dart';

/// Trạng thái lỗi toàn màn hình: icon + message thân thiện + nút Thử lại (tùy chọn).
/// Theo UI_UX_GUIDELINES.md mục Error State — không hiển thị chi tiết kỹ thuật.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(label: 'Retry', onPressed: onRetry, fullWidth: false),
            ],
          ],
        ),
      ),
    );
  }
}
