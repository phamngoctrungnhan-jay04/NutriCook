import 'dart:async';

// `firebase_auth` cũng export 1 class tên `AuthProvider` (dùng cho Google/Facebook
// Sign-In...) trùng tên với AuthProvider của app — ẩn đi vì không dùng tới.
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routing/app_router.dart';
import 'core/routing/auth_state_notifier.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';
import 'features/explore/providers/explore_provider.dart';
import 'features/explore/repositories/explore_repository.dart';
import 'features/explore/repositories/explore_repository_impl.dart';
import 'features/custom_recipe/providers/custom_recipe_provider.dart';
import 'features/custom_recipe/repositories/custom_recipe_repository.dart';
import 'features/favorite/providers/favorite_provider.dart';
import 'features/favorite/repositories/favorite_local_data_source.dart';
import 'features/favorite/repositories/favorite_remote_data_source.dart';
import 'features/favorite/repositories/favorite_repository.dart';
import 'features/favorite/repositories/favorite_repository_impl.dart';
import 'features/home/providers/meal_provider.dart';
import 'features/home/repositories/home_repository.dart';
import 'features/home/repositories/home_repository_impl.dart';
import 'features/home/services/meal_api_service.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/services/avatar_storage_service.dart';
import 'features/profile/services/profile_service.dart';

/// Composition root — nơi duy nhất khởi tạo Service/Repository/Provider và ráp
/// chúng lại (dependency injection thủ công, không dùng DI container cho MVP).
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthStateNotifier _authStateNotifier;
  late final AnalyticsService _analyticsService;
  late final HomeRepository _homeRepository;
  late final ExploreRepository _exploreRepository;
  late final FavoriteRepository _favoriteRepository;
  late final CustomRecipeRepository _customRecipeRepository;
  late final AppRouter _appRouter;

  late final AuthProvider _authProvider;
  late final MealProvider _mealProvider;
  late final ExploreProvider _exploreProvider;
  late final FavoriteProvider _favoriteProvider;
  late final ProfileProvider _profileProvider;
  late final CustomRecipeProvider _customRecipeProvider;

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateNotifier = AuthStateNotifier();
    _analyticsService = AnalyticsService();

    // 1 MealApiService dùng chung cho Home và Explore (tránh tạo 2 Dio client).
    final mealApiService = MealApiService();
    _homeRepository = HomeRepositoryImpl(mealApiService: mealApiService);
    _exploreRepository = ExploreRepositoryImpl(mealApiService: mealApiService);
    _favoriteRepository = FavoriteRepositoryImpl(
      remoteDataSource: FavoriteRemoteDataSource(),
      localDataSource: FavoriteLocalDataSource(),
    );
    _customRecipeRepository = CustomRecipeRepository();

    _authProvider = AuthProvider(
      authService: AuthService(),
      analyticsService: _analyticsService,
    );
    _mealProvider = MealProvider(homeRepository: _homeRepository);
    _exploreProvider = ExploreProvider(
      exploreRepository: _exploreRepository,
      customRecipeRepository: _customRecipeRepository,
    );
    _favoriteProvider = FavoriteProvider(favoriteRepository: _favoriteRepository);
    _profileProvider = ProfileProvider(
      profileService: ProfileService(),
      avatarStorageService: AvatarStorageService(),
    );
    _customRecipeProvider = CustomRecipeProvider(
      customRecipeRepository: _customRecipeRepository,
    );

    _appRouter = AppRouter(
      authStateNotifier: _authStateNotifier,
      homeRepository: _homeRepository,
      favoriteRepository: _favoriteRepository,
      customRecipeRepository: _customRecipeRepository,
      navigatorObserver: _analyticsService.navigatorObserver,
    );

    // Nguồn xác thực thật duy nhất cho Route Guard (FR-AUTH-02) — thay thế mọi
    // cách cập nhật thủ công trước đây, luôn phản ánh đúng trạng thái Firebase.
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
          _handleAuthStateChanged,
        );
  }

  void _handleAuthStateChanged(User? user) {
    Future.microtask(() {
      if (user == null) {
        _authStateNotifier.update(AuthStatus.unauthenticated);
        // Tránh lộ dữ liệu yêu thích của tài khoản cũ sang lần đăng nhập kế tiếp
        // trên cùng thiết bị.
        _favoriteProvider.reset();
      } else {
        _authStateNotifier.update(AuthStatus.authenticated);
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authProvider.dispose();
    _mealProvider.dispose();
    _exploreProvider.dispose();
    _favoriteProvider.dispose();
    _profileProvider.dispose();
    _customRecipeProvider.dispose();
    _authStateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _mealProvider),
        ChangeNotifierProvider.value(value: _exploreProvider),
        ChangeNotifierProvider.value(value: _favoriteProvider),
        ChangeNotifierProvider.value(value: _profileProvider),
        ChangeNotifierProvider.value(value: _customRecipeProvider),
      ],
      child: MaterialApp.router(
        title: 'NutriCook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
