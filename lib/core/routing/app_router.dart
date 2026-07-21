import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/favorite/repositories/favorite_repository.dart';
import '../../features/favorite/screens/favorite_screen.dart';
import '../../features/home/repositories/home_repository.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/meal_detail/providers/meal_detail_provider.dart';
import '../../features/meal_detail/screens/meal_detail_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';
import 'auth_state_notifier.dart';

/// Cấu hình GoRouter trung tâm của NutriCook — dùng Screen thật (không còn
/// PlaceholderScreen, đã xóa file đó vì không còn route nào cần tới).
class AppRouter {
  AppRouter({
    required this.authStateNotifier,
    required this.homeRepository,
    required this.favoriteRepository,
    NavigatorObserver? navigatorObserver,
  }) : _observers = navigatorObserver == null ? const [] : [navigatorObserver];

  final AuthStateNotifier authStateNotifier;
  final HomeRepository homeRepository;
  final FavoriteRepository favoriteRepository;
  final List<NavigatorObserver> _observers;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authStateNotifier,
    redirect: _redirect,
    observers: _observers,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.mealDetail,
                    name: RouteNames.mealDetail,
                    builder: (context, state) {
                      final idMeal = state.pathParameters['id']!;
                      // MealDetailProvider tạo mới mỗi lần vào 1 món khác nhau
                      // (không dùng singleton toàn app) — tránh lẫn dữ liệu
                      // món cũ khi vừa điều hướng sang.
                      return ChangeNotifierProvider(
                        create: (_) => MealDetailProvider(
                          homeRepository: homeRepository,
                          favoriteRepository: favoriteRepository,
                        ),
                        child: MealDetailScreen(idMeal: idMeal),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.favorite,
                name: RouteNames.favorite,
                builder: (context, state) => const FavoriteScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  String? _redirect(BuildContext context, GoRouterState state) {
    final status = authStateNotifier.status;
    final location = state.matchedLocation;

    final isSplash = location == AppRoutes.splash;
    final isAuthRoute = location == AppRoutes.login ||
        location == AppRoutes.register ||
        location == AppRoutes.forgotPassword;

    // Chưa xác định được trạng thái đăng nhập (đang chờ FirebaseAuth) — giữ ở Splash.
    if (status == AuthStatus.unknown) {
      return isSplash ? null : AppRoutes.splash;
    }

    // BR-06: Guest không được vào Home/Favorite/Profile — luôn đẩy về Login.
    if (status == AuthStatus.unauthenticated) {
      return isAuthRoute ? null : AppRoutes.login;
    }

    // Đã đăng nhập nhưng đang ở Splash/Login/Register/ForgotPassword — chuyển vào Home.
    if (isSplash || isAuthRoute) {
      return AppRoutes.home;
    }

    return null;
  }
}
