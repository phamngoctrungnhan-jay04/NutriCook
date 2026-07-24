import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Hiển thị chỉ số BMI (nếu đã có đủ chiều cao + cân nặng hiện tại) — chỉ mang
/// tính tham khảo chung, không phải tư vấn y tế.
class BmiCard extends StatelessWidget {
  const BmiCard({super.key, required this.bmi});

  final double? bmi;

  String _categoryOf(double value) {
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final value = bmi;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: value == null
            ? Text(
                'Enter height and weight to calculate BMI.',
                style: theme.textTheme.bodyMedium,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BMI Index', style: theme.textTheme.labelMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(value.toStringAsFixed(1), style: theme.textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_categoryOf(value), style: theme.textTheme.bodyMedium),
                ],
              ),
      ),
    );
  }
}
