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
import 'widgets/category_filter_widget.dart';
import 'widgets/meal_grid.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/search_suggestion_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MealProvider>()
      ..fetchDefaultMeals()
      ..loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('NutriCook')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: SearchBarWidget(),
          ),
          const SizedBox(height: AppSpacing.sm),
          const CategoryFilterWidget(),
          const SearchSuggestionWidget(),
          Expanded(child: _buildBody(mealProvider)),
        ],
      ),
    );
  }

  Widget _buildBody(MealProvider mealProvider) {
    switch (mealProvider.status) {
      case MealListStatus.idle:
      case MealListStatus.loading:
        return const LoadingIndicator();
      case MealListStatus.error:
        return ErrorView(
          message: mealProvider.errorMessage ?? 'Đã xảy ra lỗi, vui lòng thử lại.',
          onRetry: () => context.read<MealProvider>().fetchDefaultMeals(),
        );
      case MealListStatus.success:
        if (mealProvider.meals.isEmpty) {
          final isSearching = mealProvider.searchKeyword.trim().isNotEmpty;
          return EmptyStateView(
            icon: isSearching ? Icons.search_off : Icons.restaurant_menu_outlined,
            title: isSearching ? 'Không tìm thấy món ăn phù hợp' : 'Không có món ăn nào',
            description: isSearching ? 'Thử từ khóa khác hoặc chọn danh mục.' : 'Vui lòng thử lại sau.',
          );
        }
        return MealGrid(
          meals: mealProvider.meals,
          onMealTap: (meal) => _handleMealTap(context, meal),
        );
    }
  }

  void _handleMealTap(BuildContext context, MealModel meal) {
    context.goNamed(
      RouteNames.mealDetail,
      pathParameters: {'id': meal.idMeal},
    );
  }
}
