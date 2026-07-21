import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../providers/meal_provider.dart';

/// Gợi ý tìm kiếm dựa trên lịch sử (History) — nguồn dữ liệu thật duy nhất
/// (không có API autocomplete tên món ăn từ TheMealDB, xem giải thích ở
/// phần trước khi generate). Tự ẩn khi chưa có lịch sử nào.
class SearchSuggestionWidget extends StatelessWidget {
  const SearchSuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final history = mealProvider.searchHistory;

    if (history.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tìm kiếm gần đây', style: theme.textTheme.labelMedium),
              TextButton(
                onPressed: () => context.read<MealProvider>().clearSearchHistory(),
                child: const Text('Xóa'),
              ),
            ],
          ),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: history
                .map(
                  (keyword) => ActionChip(
                    label: Text(keyword),
                    onPressed: () =>
                        context.read<MealProvider>().searchImmediately(keyword),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
