import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../models/favorite_meal_model.dart';
import '../providers/favorite_provider.dart';
import 'widgets/favorite_list_item.dart';
import 'widgets/note_editor.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Yêu thích')),
      body: _buildBody(context, provider),
    );
  }

  Widget _buildBody(BuildContext context, FavoriteProvider provider) {
    switch (provider.status) {
      case FavoriteListStatus.idle:
      case FavoriteListStatus.loading:
        return const LoadingIndicator();
      case FavoriteListStatus.error:
        return ErrorView(
          message: provider.errorMessage ?? 'Đã xảy ra lỗi, vui lòng thử lại.',
        );
      case FavoriteListStatus.success:
        if (provider.favorites.isEmpty) {
          return const EmptyStateView(
            icon: Icons.favorite_border,
            title: 'Chưa có món ăn yêu thích',
            description: 'Khám phá món ăn và nhấn biểu tượng trái tim để lưu vào đây.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: provider.favorites.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final favorite = provider.favorites[index];
            return FavoriteListItem(
              favorite: favorite,
              onDelete: () => _handleDelete(context, favorite),
              onTapNote: () => NoteEditor.show(context, favorite),
            );
          },
        );
    }
  }

  void _handleDelete(BuildContext context, FavoriteMealModel favorite) {
    context.read<FavoriteProvider>().removeFavorite(favorite.idMeal);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa "${favorite.mealName}" khỏi yêu thích.')),
    );
  }
}
