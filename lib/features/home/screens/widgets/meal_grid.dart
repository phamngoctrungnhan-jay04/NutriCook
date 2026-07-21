import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/meal_model.dart';
import 'meal_card.dart';

/// GridView món ăn — số cột co giãn theo AppBreakpoints (UI_UX_GUIDELINES.md
/// mục Grid System/Responsive Strategy), dùng GridView.builder để không render
/// thừa (PROJECT_GUIDELINES.md mục Performance Rules).
class MealGrid extends StatelessWidget {
  const MealGrid({super.key, required this.meals, this.onMealTap});

  final List<MealModel> meals;
  final ValueChanged<MealModel>? onMealTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = AppBreakpoints.mealGridColumns(width);

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: meals.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final meal = meals[index];
        return MealCard(
          meal: meal,
          onTap: onMealTap == null ? null : () => onMealTap!(meal),
        );
      },
    );
  }
}
