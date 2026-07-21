import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/meal_model.dart';

/// Card món ăn — ảnh tỷ lệ 4:3 phía trên, tên tối đa 2 dòng phía dưới, toàn Card
/// có thể nhấn (UI_UX_GUIDELINES.md mục Card Design).
class MealCard extends StatelessWidget {
  const MealCard({super.key, required this.meal, this.onTap});

  final MealModel meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: AppNetworkImage(url: meal.thumbnailUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
