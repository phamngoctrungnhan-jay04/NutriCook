import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../models/meal_model.dart';
import 'meal_card.dart';

class MealCarousel extends StatefulWidget {
  const MealCarousel({
    super.key,
    required this.title,
    required this.meals,
    required this.onMealTap,
  });

  final String title;
  final List<MealModel> meals;
  final ValueChanged<MealModel> onMealTap;

  @override
  State<MealCarousel> createState() => _MealCarouselState();
}

class _MealCarouselState extends State<MealCarousel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.meals.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    final showArrow = widget.meals.length > 5;
    final displayedCount = _isExpanded
        ? widget.meals.length
        : math.min(5, widget.meals.length);

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double carouselHeight = 245 * (textScale > 1.0 ? textScale : 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (showArrow)
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.arrow_back : Icons.arrow_forward,
                    color: theme.colorScheme.primary,
                  ),
                  tooltip: _isExpanded ? 'Show less' : 'Show all',
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
            ],
          ),
        ),
        SizedBox(
          height: carouselHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: displayedCount,
            itemBuilder: (context, index) {
              final meal = widget.meals[index];
              return SizedBox(
                width: 200,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: MealCard(
                    meal: meal,
                    onTap: () => widget.onMealTap(meal),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
