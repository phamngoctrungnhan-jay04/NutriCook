import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Card gợi ý món ngẫu nhiên ("Hôm nay ăn gì?") — gọi random.php khi nhấn.
class RandomMealCard extends StatelessWidget {
  const RandomMealCard({super.key, required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.primary,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.shuffle, color: Colors.white, size: 32),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hôm nay ăn gì?',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Để chúng tôi gợi ý một món ngẫu nhiên cho bạn.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 24,
                height: 24,
                child: isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
