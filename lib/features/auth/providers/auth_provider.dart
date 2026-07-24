import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/auth_exception.dart';
import '../../../core/services/analytics_service.dart';
import '../dtos/auth_credentials_request_dto.dart';
import '../dtos/forgot_password_request_dto.dart';
import '../services/auth_service.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum AuthViewStatus { idle, loading, error }

/// State layer cho Authentication — login/register/forgot password/logout.
///
/// Không còn tự cập nhật AuthStateNotifier (khác các bước trước): từ khi có
/// Firebase Integration thật, `app.dart` lắng nghe trực tiếp
/// `FirebaseAuth.authStateChanges()` làm NGUỒN DUY NHẤT cho Route Guard —
/// tránh 2 nơi cùng ghi 1 trạng thái (dễ race condition).
class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthService authService,
    AnalyticsService? analyticsService,
  })  : _authService = authService,
        _analyticsService = analyticsService ?? AnalyticsService();

  final AuthService _authService;
  final AnalyticsService _analyticsService;

  AuthViewStatus _status = AuthViewStatus.idle;
  String? _errorMessage;
  bool _resetEmailSent = false;

  AuthViewStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthViewStatus.loading;
  bool get resetEmailSent => _resetEmailSent;

  Future<void> login({required String email, required String password}) async {
    final credentials = AuthCredentialsRequestDto(email: email, password: password);
    final validationErrors = credentials.validate();
    if (validationErrors.isNotEmpty) {
      _setError(validationErrors.first);
      return;
    }

    _status = AuthViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(credentials);
      _status = AuthViewStatus.idle;
      notifyListeners();
      unawaited(_analyticsService.logLogin());
    } on AuthException catch (e) {
      _setError(e.message);
    }
  }

  Future<void> register({required String email, required String password}) async {
    final credentials = AuthCredentialsRequestDto(email: email, password: password);
    final validationErrors = credentials.validate();
    if (validationErrors.isNotEmpty) {
      _setError(validationErrors.first);
      return;
    }

    _status = AuthViewStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(credentials);
      _status = AuthViewStatus.idle;
      notifyListeners();
      unawaited(_analyticsService.logSignUp());
    } on AuthException catch (e) {
      _setError(e.message);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final request = ForgotPasswordRequestDto(email: email);
    final validationErrors = request.validate();
    if (validationErrors.isNotEmpty) {
      _setError(validationErrors.first);
      return;
    }

    _status = AuthViewStatus.loading;
    _errorMessage = null;
    _resetEmailSent = false;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(request);
      _status = AuthViewStatus.idle;
      _resetEmailSent = true;
      notifyListeners();
    } on AuthException catch (e) {
      _setError(e.message);
    }
  }

  /// Đăng xuất (FR-PROFILE-06/FR-AUTH-09). Chỉ cần gọi FirebaseAuth.signOut() —
  /// authStateChanges() ở app.dart sẽ tự phát hiện và cập nhật Route Guard +
  /// reset FavoriteProvider.
  Future<void> logout() => _authService.logout();

  void _setError(String message) {
    _status = AuthViewStatus.error;
    _errorMessage = message;
    _resetEmailSent = false;
    notifyListeners();
  }
}
