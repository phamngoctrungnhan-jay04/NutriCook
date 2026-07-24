import 'package:flutter/material.dart';

import '../../../../core/widgets/app_network_image.dart';

/// SliverAppBar phủ ảnh món ăn — tự chuyển từ trong suốt sang nền đặc khi cuộn
/// (UI_UX_GUIDELINES.md mục AppBar), có sẵn nút yêu thích trong actions.
class MealDetailSliverAppBar extends StatelessWidget {
  const MealDetailSliverAppBar({
    super.key,
    required this.imageUrl,
    required this.isFavorited,
    required this.isToggling,
    required this.onToggleFavorite,
    this.isCustom = false,
    this.onEdit,
    this.onDelete,
  });

  final String imageUrl;
  final bool isFavorited;
  final bool isToggling;
  final VoidCallback onToggleFavorite;
  final bool isCustom;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      pinned: true,
      expandedHeight: 260,
      flexibleSpace: FlexibleSpaceBar(
        background: AppNetworkImage(url: imageUrl, fit: BoxFit.cover),
      ),
      actions: [
        if (isCustom) ...[
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: onEdit,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: onDelete,
            ),
        ] else
          IconButton(
            onPressed: isToggling ? null : onToggleFavorite,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isFavorited),
                color: isFavorited ? theme.colorScheme.primary : Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
