import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/custom_recipe/repositories/custom_recipe_repository.dart';
import '../../features/custom_recipe/screens/add_edit_recipe_screen.dart';
import '../../features/custom_recipe/screens/my_recipes_screen.dart';
import '../../features/explore/providers/category_meals_provider.dart';
import '../../features/explore/screens/category_meals_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
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
    required this.customRecipeRepository,
    NavigatorObserver? navigatorObserver,
  }) : _observers = navigatorObserver == null ? const [] : [navigatorObserver];

  final AuthStateNotifier authStateNotifier;
  final HomeRepository homeRepository;
  final FavoriteRepository favoriteRepository;
  final CustomRecipeRepository customRecipeRepository;
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
                    builder: (context, state) =>
                        _buildMealDetail(state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.explore,
                name: RouteNames.explore,
                builder: (context, state) => const ExploreScreen(),
                routes: [
                  // Meal Detail lồng riêng trong nhánh Explore — tên route khác
                  // với nhánh Home (go_router không cho trùng tên) nhưng dùng
                  // lại cùng màn hình + provider.
                  GoRoute(
                    path: AppRoutes.mealDetail,
                    name: RouteNames.exploreMealDetail,
                    builder: (context, state) =>
                        _buildMealDetail(state.pathParameters['id']!),
                  ),
                  // Trang món ăn theo danh mục (chạm 1 thẻ danh mục ở tab Khám
                  // phá). Meal Detail lồng bên trong để back trả về đúng trang
                  // danh mục thay vì về thẳng tab Khám phá.
                  GoRoute(
                    path: AppRoutes.categoryMeals,
                    name: RouteNames.exploreCategoryMeals,
                    builder: (context, state) =>
                        _buildCategoryMeals(state.pathParameters['name']!),
                    routes: [
                      GoRoute(
                        path: AppRoutes.mealDetail,
                        name: RouteNames.exploreCategoryMealDetail,
                        builder: (context, state) =>
                            _buildMealDetail(state.pathParameters['id']!),
                      ),
                    ],
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
                routes: [
                  GoRoute(
                    path: AppRoutes.myRecipes,
                    name: RouteNames.myRecipes,
                    builder: (context, state) => const MyRecipesScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: RouteNames.addRecipe,
                        builder: (context, state) => const AddEditRecipeScreen(),
                      ),
                      GoRoute(
                        path: 'edit/:id',
                        name: RouteNames.editRecipe,
                        builder: (context, state) => AddEditRecipeScreen(
                          idMeal: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'meal/:id',
                        name: RouteNames.myRecipeDetail,
                        builder: (context, state) =>
                            _buildMealDetail(state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );

  /// Dựng Meal Detail dùng chung cho cả nhánh Home và Explore. MealDetailProvider
  /// tạo mới mỗi lần vào 1 món khác nhau (không dùng singleton toàn app) — tránh
  /// lẫn dữ liệu món cũ khi vừa điều hướng sang.
  Widget _buildMealDetail(String idMeal) {
    return ChangeNotifierProvider(
      create: (_) => MealDetailProvider(
        homeRepository: homeRepository,
        favoriteRepository: favoriteRepository,
        customRecipeRepository: customRecipeRepository,
      ),
      child: MealDetailScreen(idMeal: idMeal),
    );
  }

  /// Trang món ăn theo danh mục — dùng lại HomeRepository.filterByCategory qua
  /// CategoryMealsProvider (tạo mới mỗi lần vào 1 danh mục).
  Widget _buildCategoryMeals(String category) {
    return ChangeNotifierProvider(
      create: (_) => CategoryMealsProvider(
        homeRepository: homeRepository,
        customRecipeRepository: customRecipeRepository,
      ),
      child: CategoryMealsScreen(categoryName: category),
    );
  }

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
