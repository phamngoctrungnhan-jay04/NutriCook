import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Trạng thái rỗng (chưa có Favorite, tìm kiếm không ra kết quả...).
/// Theo UI_UX_GUIDELINES.md mục Empty State — tông trung tính, không dùng
/// Primary/Error để tránh gây cảm giác đây là lỗi.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    this.description,
  });

  final IconData icon;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.textTheme.labelMedium?.color;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: secondaryColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
