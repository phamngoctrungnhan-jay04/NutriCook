import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../home/models/meal_model.dart';
import '../../home/screens/widgets/meal_grid.dart';
import '../providers/category_meals_provider.dart';

/// Trang hiển thị các món ăn thuộc 1 danh mục — mở khi chạm 1 thẻ danh mục ở
/// tab Khám phá.
class CategoryMealsScreen extends StatefulWidget {
  const CategoryMealsScreen({super.key, required this.categoryName});

  final String categoryName;

  @override
  State<CategoryMealsScreen> createState() => _CategoryMealsScreenState();
}

class _CategoryMealsScreenState extends State<CategoryMealsScreen> {
  @override
  void initState() {
    super.initState();
    // Hoãn sang sau khung hình đầu tiên (loadMeals gọi notifyListeners trước
    // await đầu tiên — gọi thẳng trong initState sẽ crash "setState during build").
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CategoryMealsProvider>().loadMeals(widget.categoryName);
    });
  }

  void _openMeal(String idMeal) {
    context.goNamed(
      RouteNames.exploreCategoryMealDetail,
      pathParameters: {'name': widget.categoryName, 'id': idMeal},
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryMealsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, CategoryMealsProvider provider) {
    switch (provider.status) {
      case CategoryMealsStatus.idle:
      case CategoryMealsStatus.loading:
        return const LoadingIndicator();
      case CategoryMealsStatus.error:
        return ErrorView(
          message: provider.errorMessage ?? 'An error occurred, please try again.',
          onRetry: () =>
              context.read<CategoryMealsProvider>().loadMeals(widget.categoryName),
        );
      case CategoryMealsStatus.success:
        if (provider.meals.isEmpty) {
          return const EmptyStateView(
            icon: Icons.restaurant_menu_outlined,
            title: 'No meals found',
            description: 'This category has no meals available.',
          );
        }
        return SingleChildScrollView(
          child: MealGrid(
            meals: provider.meals,
            pageSize: 8,
            onMealTap: (MealModel meal) => _openMeal(meal.idMeal),
          ),
        );
    }
  }
}
