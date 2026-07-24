import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../models/favorite_meal_model.dart';

/// Hàng ngang: ảnh nhỏ + tên + ghi chú rút gọn, hỗ trợ swipe-to-delete
/// (UI_UX_GUIDELINES.md mục Favorite List Item).
class FavoriteListItem extends StatelessWidget {
  const FavoriteListItem({
    super.key,
    required this.favorite,
    required this.onDelete,
    required this.onTapNote,
  });

  final FavoriteMealModel favorite;
  final VoidCallback onDelete;
  final VoidCallback onTapNote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(favorite.idMeal),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: ClipRRect(
          borderRadius: AppRadius.textFieldRadius,
          child: AppNetworkImage(
            url: favorite.mealThumbnail,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          favorite.mealName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: favorite.note.isEmpty
            ? null
            : Text(
                favorite.note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
        trailing: const Icon(Icons.edit_note_outlined),
        onTap: onTapNote,
      ),
    );
  }
}
