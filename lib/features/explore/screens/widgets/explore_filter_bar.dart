import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../providers/explore_provider.dart';
import 'category_card.dart';

/// Bộ chọn chiều lọc (Danh mục/Vùng/Nguyên liệu) + danh sách lựa chọn tương ứng:
/// - Danh mục: hàng thẻ có ảnh (CategoryCard).
/// - Vùng / Nguyên liệu: hàng chip.
class ExploreFilterBar extends StatelessWidget {
  const ExploreFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExploreProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: SegmentedButton<ExploreFilterType>(
            segments: const [
              ButtonSegment(value: ExploreFilterType.category, label: Text('Category')),
              ButtonSegment(value: ExploreFilterType.area, label: Text('Area')),
              ButtonSegment(value: ExploreFilterType.ingredient, label: Text('Ingredient')),
            ],
            selected: {provider.filterType},
            showSelectedIcon: false,
            onSelectionChanged: (selection) =>
                context.read<ExploreProvider>().selectFilterType(selection.first),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildOptions(context, provider),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, ExploreProvider provider) {
    switch (provider.filterType) {
      case ExploreFilterType.category:
        return _buildCategoryRow(context, provider);
      case ExploreFilterType.area:
        return _buildSearchField(context, provider, provider.areas, 'Enter area name...');
      case ExploreFilterType.ingredient:
        return _buildSearchField(
          context,
          provider,
          provider.ingredients,
          'Enter ingredient name...',
        );
    }
  }

  /// Danh mục: lưới đều cột (số cột co theo bề rộng như lưới món ăn) — thẻ tự
  /// lấp đầy hàng, không cuộn ngang. shrinkWrap + NeverScrollable để nằm gọn
  /// trong ListView cha của ExploreScreen.
  Widget _buildCategoryRow(BuildContext context, ExploreProvider provider) {
    if (provider.categories.isEmpty) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    final columns = AppBreakpoints.mealGridColumns(width);
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double adjustedAspectRatio = 0.85 / (textScale > 1.0 ? textScale : 1.0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: provider.categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: adjustedAspectRatio,
      ),
      itemBuilder: (context, index) {
        final category = provider.categories[index];
        return CategoryCard(
          category: category,
          isSelected: false,
          // Chạm 1 danh mục → sang trang riêng hiển thị món của danh mục đó.
          onTap: () => context.goNamed(
            RouteNames.exploreCategoryMeals,
            pathParameters: {'name': category.name},
          ),
        );
      },
    );
  }

  /// Vùng / Nguyên liệu: ô gõ tìm có gợi ý — lọc client-side trên list đã tải sẵn
  /// (không gọi API mỗi lần gõ). Chọn 1 gợi ý → lọc món ngay.
  Widget _buildSearchField(
    BuildContext context,
    ExploreProvider provider,
    List<String> values,
    String hintText,
  ) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Autocomplete<String>(
        // Reset ô gõ khi chuyển giữa Vùng ↔ Nguyên liệu (cả hai cùng dùng widget này).
        key: ValueKey(provider.filterType),
        optionsBuilder: (textValue) {
          final input = textValue.text.trim().toLowerCase();
          if (input.isEmpty) return const Iterable<String>.empty();
          return values.where((v) => v.toLowerCase().contains(input));
        },
        onSelected: (selection) =>
            context.read<ExploreProvider>().selectValue(selection),
        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (_) => onFieldSubmitted(),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
            ),
          );
        },
      ),
    );
  }
}
