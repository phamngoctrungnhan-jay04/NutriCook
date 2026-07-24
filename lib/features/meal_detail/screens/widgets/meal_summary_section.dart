import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class MealSummarySection extends StatelessWidget {
  const MealSummarySection({super.key, required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    if (summary.trim().isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About the recipe', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withAlpha(204),
            ),
          ),
        ],
      ),
    );
  }
}
