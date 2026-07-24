import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/meal_model.dart';
import '../providers/meal_provider.dart';
import 'widgets/ingredient_filter_bar.dart';
import 'widgets/meal_carousel.dart';
import 'widgets/meal_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Hoãn sang sau khung hình đầu tiên: MealProvider.fetchDefaultMeals() gọi
    // notifyListeners() trước await đầu tiên, nếu gọi thẳng trong initState()
    // sẽ chạy đồng bộ ngay lúc cây widget đang được dựng lần đầu (Flutter ném
    // "setState()/markNeedsBuild() called during build").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MealProvider>()
        ..fetchDefaultMeals()
        ..loadIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final isFilterActive = mealProvider.selectedIngredients.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('NutriCook')),
      body: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          const IngredientFilterBar(),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _buildBody(mealProvider, isFilterActive)),
        ],
      ),
    );
  }

  Widget _buildBody(MealProvider mealProvider, bool isFilterActive) {
    switch (mealProvider.status) {
      case MealListStatus.idle:
      case MealListStatus.loading:
        return const LoadingIndicator();
      case MealListStatus.error:
        return ErrorView(
          message: mealProvider.errorMessage ?? 'An error occurred, please try again.',
          onRetry: () => context.read<MealProvider>().fetchDefaultMeals(),
        );
      case MealListStatus.success:
        if (mealProvider.meals.isEmpty) {
          return const EmptyStateView(
            icon: Icons.restaurant_menu_outlined,
            title: 'No meals available',
            description: 'Please try selecting different ingredients or try again later.',
          );
        }

        // Đang lọc theo nguyên liệu thì hiện lưới dọc kết quả
        if (isFilterActive) {
          return SingleChildScrollView(
            child: MealGrid(
              meals: mealProvider.meals,
              pageSize: 8,
              onMealTap: (meal) => _handleMealTap(context, meal),
            ),
          );
        }

        // Chế độ mặc định của trang chủ
        return _buildCarousels(mealProvider.meals);
    }
  }

  Widget _buildCarousels(List<MealModel> allMeals) {
    final meatMains = allMeals.where((meal) {
      final cat = meal.category?.toLowerCase() ?? '';
      return cat == 'beef' ||
          cat == 'chicken' ||
          cat == 'lamb' ||
          cat == 'pork' ||
          cat == 'goat' ||
          cat == 'miscellaneous';
    }).toList();

    final seafoodVeggie = allMeals.where((meal) {
      final cat = meal.category?.toLowerCase() ?? '';
      return cat == 'seafood' || cat == 'vegetarian' || cat == 'vegan' || cat == 'pasta';
    }).toList();

    final sidesDesserts = allMeals.where((meal) {
      final cat = meal.category?.toLowerCase() ?? '';
      return cat == 'dessert' || cat == 'side' || cat == 'starter' || cat == 'breakfast';
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          MealCarousel(
            title: 'Lunch Recommendations 🍲',
            meals: meatMains,
            onMealTap: (meal) => _handleMealTap(context, meal),
          ),
          MealCarousel(
            title: 'Eat Clean & Healthy 🥗',
            meals: seafoodVeggie,
            onMealTap: (meal) => _handleMealTap(context, meal),
          ),
          MealCarousel(
            title: 'Sides & Desserts 🍰',
            meals: sidesDesserts,
            onMealTap: (meal) => _handleMealTap(context, meal),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _handleMealTap(BuildContext context, MealModel meal) {
    context.goNamed(
      RouteNames.mealDetail,
      pathParameters: {'id': meal.idMeal},
    );
  }
}
