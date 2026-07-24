import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../providers/meal_provider.dart';
import 'ingredient_filter_sheet.dart';

/// Thanh bộ lọc nguyên liệu — nút "Bộ lọc" mở bottom sheet chọn nhiều nguyên liệu.
/// Hiện số nguyên liệu đang lọc; khi có lọc thì thêm nút "Xóa lọc".
class IngredientFilterBar extends StatelessWidget {
  const IngredientFilterBar({super.key});

  Future<void> _openSheet(BuildContext context, MealProvider provider) async {
    final result = await IngredientFilterSheet.show(
      context,
      ingredients: provider.ingredients,
      selected: provider.selectedIngredients,
    );
    if (result == null || !context.mounted) return;
    await context.read<MealProvider>().applyIngredients(result);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();

    // Chưa tải kịp nguyên liệu thì ẩn cả thanh.
    if (provider.ingredients.isEmpty) return const SizedBox.shrink();

    final count = provider.selectedIngredients.length;
    final label = count == 0 ? 'Filter ingredients' : 'Filter ingredients ($count)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          OutlinedButton.icon(
            // Override minimumSize: theme đặt Size.fromHeight(48) (min width vô
            // hạn = full-width) — trong Row sẽ ép nút rộng vô hạn gây vỡ layout.
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => _openSheet(context, provider),
            icon: const Icon(Icons.filter_list),
            label: Text(label),
          ),
          if (count > 0) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => context.read<MealProvider>().applyIngredients({}),
              child: const Text('Clear filter'),
            ),
          ],
        ],
      ),
    );
  }
}
