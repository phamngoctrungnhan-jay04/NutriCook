import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../favorite/providers/favorite_provider.dart';
import '../../models/meal_model.dart';

/// Card món ăn — ảnh tỷ lệ 4:3 phía trên có nút Lưu nhanh, tên và các thông số nấu
/// ăn ở phía dưới. Toàn bộ Card có thể nhấn.
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: AppNetworkImage(url: meal.thumbnailUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: AppSpacing.xs,
                  right: AppSpacing.xs,
                  child: Consumer<FavoriteProvider>(
                    builder: (context, favProvider, _) {
                      final isFavorited = favProvider.favorites
                          .any((fav) => fav.idMeal == meal.idMeal);
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black.withAlpha(102),
                        child: IconButton(
                          iconSize: 16,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            color: isFavorited ? Colors.red : Colors.white,
                          ),
                          onPressed: () => favProvider.toggleFavorite(meal),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.xs,
              ),
              child: Text(
                meal.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                0,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_outlined,
                        size: 13,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${meal.calories} kcal',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${meal.cookingTime}m',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(76),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      meal.difficulty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

