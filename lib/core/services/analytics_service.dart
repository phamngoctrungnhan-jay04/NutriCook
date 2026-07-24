import 'package:firebase_analytics/firebase_analytics.dart';

/// Wrapper mỏng quanh FirebaseAnalytics — chỉ log các sự kiện có giá trị rõ
/// ràng (đăng nhập/đăng ký), tránh nhồi nhét event chưa có nhu cầu phân tích cụ
/// thể. `navigatorObserver` gắn vào GoRouter để tự động log screen view, không
/// cần gọi tay ở từng Screen.
class AnalyticsService {
  AnalyticsService({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalyticsObserver get navigatorObserver =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin() => _analytics.logLogin(loginMethod: 'email');

  Future<void> logSignUp() => _analytics.logSignUp(signUpMethod: 'email');
}
