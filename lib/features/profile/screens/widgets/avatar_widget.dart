import 'package:flutter/material.dart';

/// Avatar — hiển thị ảnh thật (avatarUrl) nếu có, fallback về chữ cái đầu tên
/// (initials) nếu chưa tải ảnh lên. Có thể kèm nút sửa (icon camera nhỏ góc dưới).
class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 40,
    this.onEdit,
    this.isUploading = false,
  });

  final String name;
  final String? avatarUrl;
  final double radius;
  final VoidCallback? onEdit;
  final bool isUploading;

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.substring(0, 1);
    final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.primary,
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    _initials,
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
          ),
          if (isUploading)
            Positioned.fill(
              child: CircleAvatar(
                radius: radius,
                backgroundColor: Colors.black45,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
              ),
            ),
          if (onEdit != null && !isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onEdit,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: theme.colorScheme.secondary,
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
