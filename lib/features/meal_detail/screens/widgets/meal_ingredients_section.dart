import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../home/models/meal_model.dart';

class MealIngredientsSection extends StatelessWidget {
  const MealIngredientsSection({super.key, required this.ingredients});

  final List<MealIngredient> ingredients;

  @override
  Widget build(BuildContext context) {
    if (ingredients.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final secondaryColor = theme.textTheme.labelMedium?.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, 0),
      child: ExpansionTile(
        title: Text('Ingredients', style: theme.textTheme.titleLarge),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: AppSpacing.sm),
        initiallyExpanded: false,
        shape: const Border(),
        collapsedShape: const Border(),
        children: ingredients.map(
          (ingredient) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(ingredient.name, style: theme.textTheme.bodyMedium),
                ),
                Text(
                  ingredient.measure,
                  style: theme.textTheme.bodyMedium?.copyWith(color: secondaryColor),
                ),
              ],
            ),
          ),
        ).toList(),
      ),
    );
  }
}
