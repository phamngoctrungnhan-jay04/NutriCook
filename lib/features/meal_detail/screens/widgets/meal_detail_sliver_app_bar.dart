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
  });

  final String imageUrl;
  final bool isFavorited;
  final bool isToggling;
  final VoidCallback onToggleFavorite;

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
