import 'package:flutter/material.dart';

import 'loading_indicator.dart';

/// Ảnh từ URL (dùng cho ảnh món ăn từ TheMealDB), có sẵn trạng thái loading/lỗi.
/// Đặt tên AppNetworkImage (không phải NetworkImage) vì Flutter đã có sẵn class
/// `NetworkImage` (ImageProvider) — trùng tên sẽ gây nhầm lẫn khi import material.dart.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final image = Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: width,
          height: height,
          child: const LoadingIndicator(size: 24),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: theme.colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.broken_image_outlined,
            color: theme.textTheme.labelMedium?.color,
          ),
        );
      },
    );

    if (borderRadius == null) return image;
    return ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
