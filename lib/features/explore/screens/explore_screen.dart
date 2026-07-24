import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../home/models/meal_model.dart';
import '../../home/screens/widgets/meal_grid.dart';
import '../providers/explore_provider.dart';
import 'widgets/explore_filter_bar.dart';
import 'widgets/random_meal_card.dart';

/// Tab Khám phá — món ngẫu nhiên + lọc theo Danh mục/Vùng/Nguyên liệu.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isPickingRandom = false;

  @override
  void initState() {
    super.initState();
    // Hoãn sang sau khung hình đầu tiên — loadInitial() gọi notifyListeners()
    // trước await đầu tiên (giống HomeScreen), gọi thẳng trong initState() sẽ
    // crash "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ExploreProvider>().loadInitial();
    });
  }

  Future<void> _handleRandom() async {
    setState(() => _isPickingRandom = true);
    final idMeal = await context.read<ExploreProvider>().pickRandomMeal();
    if (!mounted) return;
    setState(() => _isPickingRandom = false);

    if (idMeal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick a random meal, please try again.')),
      );
      return;
    }
    _openMeal(idMeal);
  }

  void _openMeal(String idMeal) {
    context.goNamed(
      RouteNames.exploreMealDetail,
      pathParameters: {'id': idMeal},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: RandomMealCard(isLoading: _isPickingRandom, onTap: _handleRandom),
          ),
          const ExploreFilterBar(),
          const SizedBox(height: AppSpacing.md),
          _buildResults(context),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final provider = context.watch<ExploreProvider>();

    // Danh mục: kết quả hiển thị ở trang riêng (CategoryMealsScreen), không hiện
    // lưới inline ở đây. Chỉ Vùng/Nguyên liệu mới lọc và hiện kết quả tại chỗ.
    if (provider.filterType == ExploreFilterType.category) {
      return const SizedBox.shrink();
    }

    switch (provider.status) {
      case ExploreListStatus.idle:
        return const _ResultsHint();
      case ExploreListStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: LoadingIndicator(),
        );
      case ExploreListStatus.error:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: ErrorView(
            message: provider.errorMessage ?? 'An error occurred, please try again.',
            onRetry: () => context.read<ExploreProvider>().retryLastSelection(),
          ),
        );
      case ExploreListStatus.success:
        if (provider.meals.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: EmptyStateView(
              icon: Icons.restaurant_menu_outlined,
              title: 'No meals found',
              description: 'Try selecting a different option.',
            ),
          );
        }
        // Lưới nằm trong ListView cha — chế độ phân trang (pageSize) tự bật
        // shrinkWrap + tắt cuộn riêng nên không xung đột scroll.
        return MealGrid(
          meals: provider.meals,
          pageSize: 8,
          onMealTap: (MealModel meal) => _openMeal(meal.idMeal),
        );
    }
  }
}

/// Gợi ý ban đầu khi người dùng chưa chọn lựa chọn lọc nào.
class _ResultsHint extends StatelessWidget {
  const _ResultsHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: EmptyStateView(
        icon: Icons.touch_app_outlined,
        title: 'Select an option to view meals',
        description: 'Choose a category, area, or ingredient above.',
      ),
    );
  }
}
