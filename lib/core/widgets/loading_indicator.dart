import 'package:flutter/material.dart';

/// Spinner dùng chung cho mọi trạng thái loading (toàn màn hình hoặc cục bộ).
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
