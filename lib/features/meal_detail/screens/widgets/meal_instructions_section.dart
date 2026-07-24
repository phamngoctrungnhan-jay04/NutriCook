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
      child: ExpansionTile(
        title: Text('Instructions', style: theme.textTheme.titleLarge),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
