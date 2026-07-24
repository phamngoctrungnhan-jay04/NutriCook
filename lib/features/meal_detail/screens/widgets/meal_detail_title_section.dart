import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../home/models/meal_model.dart';

class MealDetailTitleSection extends StatelessWidget {
  const MealDetailTitleSection({super.key, required this.meal});

  final MealModel meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(meal.name, style: theme.textTheme.headlineSmall),
          if (meal.category != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Chip(label: Text(meal.category!)),
          ],
        ],
      ),
    );
  }
}
