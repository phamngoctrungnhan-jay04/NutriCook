/// Path (dùng cho URL/deep link) và name (dùng cho `context.goNamed`) của mọi route.
/// Tập trung tại đây để tránh hard-code chuỗi route rải rác (Named Route).
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String favorite = '/favorite';
  static const String profile = '/profile';

  /// Relative path, lồng bên trong nhánh Home: path đầy đủ là `/home/meal/:id`.
  static const String mealDetail = 'meal/:id';

  static String mealDetailPath(String id) => '/home/meal/$id';
}

class RouteNames {
  const RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';

  static const String home = 'home';
  static const String favorite = 'favorite';
  static const String profile = 'profile';

  static const String mealDetail = 'mealDetail';
}
