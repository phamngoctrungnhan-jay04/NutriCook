import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/primary_button.dart';
import '../../home/screens/widgets/meal_grid.dart';
import '../providers/custom_recipe_provider.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  void _openMeal(BuildContext context, String idMeal) {
    context.goNamed(
      RouteNames.myRecipeDetail,
      pathParameters: {'id': idMeal},
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomRecipeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Recipes'),
      ),
      body: _buildBody(context, provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.goNamed(RouteNames.addRecipe),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CustomRecipeProvider provider) {
    switch (provider.status) {
      case CustomRecipeStatus.idle:
      case CustomRecipeStatus.loading:
        return const LoadingIndicator();
      case CustomRecipeStatus.error:
        return ErrorView(
          message: provider.errorMessage ?? 'An error occurred, please try again.',
          onRetry: () {}, // Handled by Firestore stream auto-retry/reconnect
        );
      case CustomRecipeStatus.success:
        if (provider.recipes.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmptyStateView(
                    icon: Icons.restaurant_menu_outlined,
                    title: 'Create your first recipe',
                    description: 'Save your favorite custom dishes in one place.',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Add Recipe',
                    onPressed: () => context.goNamed(RouteNames.addRecipe),
                  ),
                ],
              ),
            ),
          );
        }

        return MealGrid(
          meals: provider.recipes,
          pageSize: 10,
          onMealTap: (meal) => _openMeal(context, meal.idMeal),
        );
    }
  }
}
