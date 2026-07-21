import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class MealInstructionsSection extends StatelessWidget {
  const MealInstructionsSection({super.key, required this.instructions});

  final String? instructions;

  @override
  Widget build(BuildContext context) {
    final text = instructions?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hướng dẫn thực hiện', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
