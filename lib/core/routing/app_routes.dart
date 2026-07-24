/// Path (dùng cho URL/deep link) và name (dùng cho `context.goNamed`) của mọi route.
/// Tập trung tại đây để tránh hard-code chuỗi route rải rác (Named Route).
class AppRoutes {
  const AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String explore = '/explore';
  static const String favorite = '/favorite';
  static const String profile = '/profile';

  /// Relative paths lồng trong Profile branch
  static const String myRecipes = 'my-recipes';
  static const String addRecipe = 'my-recipes/add';
  static const String editRecipe = 'my-recipes/edit/:id';
  static const String myRecipeDetail = 'my-recipes/meal/:id';

  /// Relative path, lồng bên trong nhánh Home: path đầy đủ là `/home/meal/:id`.
  static const String mealDetail = 'meal/:id';

  /// Relative path, lồng trong nhánh Explore: `/explore/category/:name`.
  static const String categoryMeals = 'category/:name';

  static String mealDetailPath(String id) => '/home/meal/$id';

  static String exploreMealDetailPath(String id) => '/explore/meal/$id';

  static String myRecipesPath() => '/profile/my-recipes';
  static String addRecipePath() => '/profile/my-recipes/add';
  static String editRecipePath(String id) => '/profile/my-recipes/edit/$id';
  static String myRecipeDetailPath(String id) => '/profile/my-recipes/meal/$id';
}

class RouteNames {
  const RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';

  static const String home = 'home';
  static const String explore = 'explore';
  static const String favorite = 'favorite';
  static const String profile = 'profile';

  static const String myRecipes = 'myRecipes';
  static const String addRecipe = 'addRecipe';
  static const String editRecipe = 'editRecipe';
  static const String myRecipeDetail = 'myRecipeDetail';

  static const String mealDetail = 'mealDetail';
  static const String exploreMealDetail = 'exploreMealDetail';
  static const String exploreCategoryMeals = 'exploreCategoryMeals';
  static const String exploreCategoryMealDetail = 'exploreCategoryMealDetail';
}
