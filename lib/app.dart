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
  late final FavoriteRepository _favoriteRepository;
  late final AppRouter _appRouter;

  late final AuthProvider _authProvider;
  late final MealProvider _mealProvider;
  late final FavoriteProvider _favoriteProvider;
  late final ProfileProvider _profileProvider;

  StreamSubscription<User?>? _authStateSubscription;

  @override
  void initState() {
    super.initState();

    _authStateNotifier = AuthStateNotifier();
    _analyticsService = AnalyticsService();

    _homeRepository = HomeRepositoryImpl(mealApiService: MealApiService());
    _favoriteRepository = FavoriteRepositoryImpl(
      remoteDataSource: FavoriteRemoteDataSource(),
      localDataSource: FavoriteLocalDataSource(),
    );

    _authProvider = AuthProvider(
      authService: AuthService(),
      analyticsService: _analyticsService,
    );
    _mealProvider = MealProvider(homeRepository: _homeRepository);
    _favoriteProvider = FavoriteProvider(favoriteRepository: _favoriteRepository);
    _profileProvider = ProfileProvider(
      profileService: ProfileService(),
      avatarStorageService: AvatarStorageService(),
    );

    _appRouter = AppRouter(
      authStateNotifier: _authStateNotifier,
      homeRepository: _homeRepository,
      favoriteRepository: _favoriteRepository,
      navigatorObserver: _analyticsService.navigatorObserver,
    );

    // Nguồn xác thực thật duy nhất cho Route Guard (FR-AUTH-02) — thay thế mọi
    // cách cập nhật thủ công trước đây, luôn phản ánh đúng trạng thái Firebase.
    _authStateSubscription = FirebaseAuth.instance.authStateChanges().listen(
          _handleAuthStateChanged,
        );
  }

  void _handleAuthStateChanged(User? user) {
    if (user == null) {
      _authStateNotifier.update(AuthStatus.unauthenticated);
      // Tránh lộ dữ liệu yêu thích của tài khoản cũ sang lần đăng nhập kế tiếp
      // trên cùng thiết bị.
      _favoriteProvider.reset();
    } else {
      _authStateNotifier.update(AuthStatus.authenticated);
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _authProvider.dispose();
    _mealProvider.dispose();
    _favoriteProvider.dispose();
    _profileProvider.dispose();
    _authStateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _mealProvider),
        ChangeNotifierProvider.value(value: _favoriteProvider),
        ChangeNotifierProvider.value(value: _profileProvider),
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
