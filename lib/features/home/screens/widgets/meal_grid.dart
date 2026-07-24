import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_breakpoints.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/meal_model.dart';
import 'meal_card.dart';

/// GridView món ăn — số cột co giãn theo AppBreakpoints (UI_UX_GUIDELINES.md
/// mục Grid System/Responsive Strategy), dùng GridView.builder để không render
/// thừa (PROJECT_GUIDELINES.md mục Performance Rules).
///
/// [pageSize] != null bật phân trang "Hiển thị thêm": ban đầu chỉ hiện tối đa
/// [pageSize] món, bấm nút dưới cùng để hiện thêm mỗi lần [pageSize] món. Ở chế
/// độ này lưới luôn shrinkWrap + không cuộn riêng nên PHẢI đặt trong một scroll
/// cha (SingleChildScrollView/ListView). [pageSize] == null giữ hành vi cũ.
class MealGrid extends StatefulWidget {
  const MealGrid({
    super.key,
    required this.meals,
    this.onMealTap,
    this.shrinkWrap = false,
    this.physics,
    this.pageSize,
  });

  final List<MealModel> meals;
  final ValueChanged<MealModel>? onMealTap;

  /// Khi nhúng lưới bên trong một ListView/CustomScroll khác (ví dụ tab Khám
  /// phá), truyền `shrinkWrap: true` + `physics: NeverScrollableScrollPhysics()`
  /// để lưới không cuộn riêng, tránh xung đột với scroll cha.
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  /// Số món hiện mỗi "trang". null = hiện hết (không phân trang).
  final int? pageSize;

  @override
  State<MealGrid> createState() => _MealGridState();
}

class _MealGridState extends State<MealGrid> {
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = widget.pageSize ?? widget.meals.length;
  }

  @override
  void didUpdateWidget(MealGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Danh sách đổi (lọc/tìm lại) → reset về trang đầu.
    if (oldWidget.meals != widget.meals) {
      _visibleCount = widget.pageSize ?? widget.meals.length;
    }
  }

  void _showMore() {
    setState(() {
      _visibleCount =
          math.min(_visibleCount + (widget.pageSize ?? 0), widget.meals.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = AppBreakpoints.mealGridColumns(width);

    final isPaginated = widget.pageSize != null;
    final count = isPaginated
        ? math.min(_visibleCount, widget.meals.length)
        : widget.meals.length;

    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final double adjustedAspectRatio = 0.78 / (textScale > 1.0 ? textScale : 1.0);

    final grid = GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      shrinkWrap: isPaginated ? true : widget.shrinkWrap,
      physics: isPaginated ? const NeverScrollableScrollPhysics() : widget.physics,
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: adjustedAspectRatio,
      ),
      itemBuilder: (context, index) {
        final meal = widget.meals[index];
        return MealCard(
          meal: meal,
          onTap: widget.onMealTap == null ? null : () => widget.onMealTap!(meal),
        );
      },
    );

    if (!isPaginated) return grid;

    final hasMore = count < widget.meals.length;
    return Column(
      children: [
        grid,
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: OutlinedButton.icon(
              onPressed: _showMore,
              icon: const Icon(Icons.expand_more),
              label: Text('Hiển thị thêm (${widget.meals.length - count})'),
            ),
          ),
      ],
    );
  }
}
