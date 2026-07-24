import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../custom_recipe/providers/custom_recipe_provider.dart';
import '../providers/meal_detail_provider.dart';
import 'widgets/meal_detail_sliver_app_bar.dart';
import 'widgets/meal_detail_title_section.dart';
import 'widgets/meal_ingredients_section.dart';
import 'widgets/meal_instructions_section.dart';
import 'widgets/meal_summary_section.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({super.key, required this.idMeal});

  final String idMeal;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Hoãn sang sau khung hình đầu tiên — cùng lý do như HomeScreen (xem
    // home_screen.dart): loadMeal() gọi notifyListeners() trước await đầu
    // tiên, gọi thẳng trong initState() sẽ crash lúc màn hình đang được dựng.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MealDetailProvider>().loadMeal(widget.idMeal);
    });
  }

  Future<void> _handleDeleteCustomRecipe(BuildContext context, String idMeal) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Recipe',
      message: 'Are you sure you want to delete this custom recipe?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final success = await context.read<CustomRecipeProvider>().deleteRecipe(idMeal);
    if (!context.mounted) return;

    if (success) {
      context.pop(); // Quay lại trang danh sách món ăn tự tạo
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete recipe, please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealDetailProvider>();
    final isCustom = widget.idMeal.startsWith('custom_');

    if (provider.status == MealDetailStatus.success) {
      final meal = provider.meal!;
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            MealDetailSliverAppBar(
              imageUrl: meal.thumbnailUrl,
              isFavorited: provider.isFavorited,
              isToggling: provider.isTogglingFavorite,
              onToggleFavorite: () => context.read<MealDetailProvider>().toggleFavorite(),
              isCustom: isCustom,
              onEdit: () => context.goNamed(
                RouteNames.editRecipe,
                pathParameters: {'id': meal.idMeal},
              ),
              onDelete: () => _handleDeleteCustomRecipe(context, meal.idMeal),
            ),
            SliverToBoxAdapter(child: MealDetailTitleSection(meal: meal)),
            SliverToBoxAdapter(child: MealSummarySection(summary: meal.summary)),
            SliverToBoxAdapter(child: MealIngredientsSection(ingredients: meal.ingredients)),
            SliverToBoxAdapter(child: MealInstructionsSection(instructions: meal.instructions)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: provider.status == MealDetailStatus.error
          ? ErrorView(
              message: provider.errorMessage ?? 'An error occurred, please try again.',
              onRetry: () => context.read<MealDetailProvider>().loadMeal(widget.idMeal),
            )
          : const LoadingIndicator(),
    );
  }
}
