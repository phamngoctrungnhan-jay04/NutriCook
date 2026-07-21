import 'package:flutter/foundation.dart';

/// Trạng thái xác thực dùng cho Route Guard.
///
/// `unknown` = chưa xác định được (đang chờ FirebaseAuth trả kết quả lần đầu) —
/// giữ người dùng ở Splash cho tới khi có kết quả rõ ràng.
enum AuthStatus { unknown, authenticated, unauthenticated }

/// Cầu nối trung lập giữa AppRouter và tầng Authentication.
///
/// AppRouter chỉ biết tới class này, không phụ thuộc trực tiếp vào AuthProvider
/// (chưa tồn tại ở thời điểm xây Navigation System — sẽ được xây ở Phase 5 theo
/// DEVELOPMENT_ROADMAP.md). Khi Phase 5 triển khai AuthProvider thật, nó sẽ gọi
/// `update(...)` mỗi khi `FirebaseAuth.authStateChanges()` phát tín hiệu, mà không
/// cần sửa lại bất kỳ file nào trong core/routing/.
class AuthStateNotifier extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;

  AuthStatus get status => _status;

  void update(AuthStatus status) {
    if (_status == status) return;
    _status = status;
    notifyListeners();
  }
}
