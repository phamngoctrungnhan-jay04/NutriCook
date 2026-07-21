import 'package:flutter/material.dart';

import '../../../core/widgets/loading_indicator.dart';

/// Hiển thị trong lúc chờ Firebase xác định trạng thái đăng nhập ban đầu
/// (FR-AUTH-01/02) — AppRouter tự động điều hướng đi khi AuthStateNotifier
/// thoát trạng thái `unknown` (xem app.dart, listener authStateChanges()).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingIndicator());
  }
}
