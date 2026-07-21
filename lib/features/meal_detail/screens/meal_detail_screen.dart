import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../providers/meal_detail_provider.dart';
import 'widgets/meal_detail_sliver_app_bar.dart';
import 'widgets/meal_detail_title_section.dart';
import 'widgets/meal_ingredients_section.dart';
import 'widgets/meal_instructions_section.dart';

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
    context.read<MealDetailProvider>().loadMeal(widget.idMeal);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealDetailProvider>();

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
            ),
            SliverToBoxAdapter(child: MealDetailTitleSection(meal: meal)),
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
              message: provider.errorMessage ?? 'Đã xảy ra lỗi, vui lòng thử lại.',
              onRetry: () => context.read<MealDetailProvider>().loadMeal(widget.idMeal),
            )
          : const LoadingIndicator(),
    );
  }
}
