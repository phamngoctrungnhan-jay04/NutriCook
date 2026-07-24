import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../custom_recipe/repositories/custom_recipe_repository.dart';
import '../../home/models/meal_model.dart';
import '../models/meal_category_model.dart';
import '../repositories/explore_repository.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum ExploreListStatus { idle, loading, success, error }

/// 3 chiều lọc trong tab Khám phá — mỗi chiều dùng 1 endpoint filter khác nhau.
enum ExploreFilterType { category, area, ingredient }

/// ViewModel cho tab Khám phá — quản lý danh mục (kèm ảnh), vùng, nguyên liệu,
/// và lưới kết quả khi chọn 1 giá trị lọc. Tách khỏi MealProvider (Home) để
/// chuyển tab qua lại không làm mất trạng thái của nhau.
class ExploreProvider extends ChangeNotifier {
  ExploreProvider({
    required ExploreRepository exploreRepository,
    CustomRecipeRepository? customRecipeRepository,
    FirebaseAuth? firebaseAuth,
  })  : _repository = exploreRepository,
        _customRecipeRepository = customRecipeRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final ExploreRepository _repository;
  final CustomRecipeRepository? _customRecipeRepository;
  final FirebaseAuth _firebaseAuth;

  ExploreListStatus _status = ExploreListStatus.idle;
  List<MealModel> _meals = const [];
  String? _errorMessage;

  ExploreFilterType _filterType = ExploreFilterType.category;
  List<MealCategoryModel> _categories = const [];
  List<String> _areas = const [];
  List<String> _ingredients = const [];
  String? _selectedValue;

  ExploreListStatus get status => _status;
  List<MealModel> get meals => _meals;
  String? get errorMessage => _errorMessage;

  ExploreFilterType get filterType => _filterType;
  List<MealCategoryModel> get categories => _categories;
  List<String> get areas => _areas;
  List<String> get ingredients => _ingredients;
  String? get selectedValue => _selectedValue;

  /// Nạp 3 danh sách lọc song song. Lỗi tải danh sách chỉ là phụ (không có kết
  /// quả để lọc) — không đặt _status = error để khỏi chặn cả màn hình; UI tự ẩn
  /// hàng chip rỗng. Giống cách MealProvider.loadCategories xử lý.
  Future<void> loadInitial() async {
    final results = await Future.wait([
      _safeLoad(_repository.getCategories),
      _safeLoad(_repository.getAreas),
      _safeLoad(_repository.getIngredients),
    ]);

    _categories = results[0] as List<MealCategoryModel>;
    _areas = results[1] as List<String>;
    _ingredients = results[2] as List<String>;
    notifyListeners();
  }

  Future<List<T>> _safeLoad<T>(Future<List<T>> Function() action) async {
    try {
      return await action();
    } on AppException {
      return const [];
    }
  }

  /// Đổi chiều lọc (Danh mục/Vùng/Nguyên liệu) — reset lựa chọn và lưới kết quả
  /// cũ để tránh hiển thị kết quả của chiều lọc trước.
  void selectFilterType(ExploreFilterType type) {
    if (_filterType == type) return;
    _filterType = type;
    _selectedValue = null;
    _meals = const [];
    _status = ExploreListStatus.idle;
    notifyListeners();
  }

  /// Chọn 1 giá trị lọc (tên danh mục/vùng/nguyên liệu) → gọi endpoint filter
  /// tương ứng với chiều lọc đang chọn.
  Future<void> selectValue(String value) async {
    _selectedValue = value;
    final valueLower = value.toLowerCase();
    final uid = _firebaseAuth.currentUser?.uid;

    await _runFetch(() async {
      List<MealModel> apiMeals = [];
      try {
        switch (_filterType) {
          case ExploreFilterType.category:
            apiMeals = await _repository.filterByCategory(value);
          case ExploreFilterType.area:
            apiMeals = await _repository.filterByArea(value);
          case ExploreFilterType.ingredient:
            apiMeals = await _repository.filterByIngredient(value);
        }
      } catch (e) {
        debugPrint('[ExploreProvider] Public API search error: $e');
      }

      List<MealModel> customMeals = [];
      if (uid != null && _customRecipeRepository != null) {
        try {
          final allCustom = await _customRecipeRepository.watchCustomRecipes(uid).first;
          switch (_filterType) {
            case ExploreFilterType.category:
              customMeals = allCustom
                  .where((m) => m.category?.toLowerCase() == valueLower)
                  .toList();
            case ExploreFilterType.area:
              customMeals = allCustom
                  .where((m) => m.area?.toLowerCase() == valueLower)
                  .toList();
            case ExploreFilterType.ingredient:
              customMeals = allCustom
                  .where((m) => m.ingredients.any(
                      (i) => i.name.toLowerCase().contains(valueLower)))
                  .toList();
          }
        } catch (e) {
          debugPrint('[ExploreProvider] Custom recipes search error: $e');
        }
      }

      return [...customMeals, ...apiMeals];
    });
  }

  /// Lấy 1 món ngẫu nhiên, trả idMeal để màn hình điều hướng sang Meal Detail.
  /// null nếu lỗi/không có kết quả (màn hình hiển thị SnackBar).
  Future<String?> pickRandomMeal() async {
    try {
      final meal = await _repository.getRandomMeal();
      return meal?.idMeal;
    } on AppException {
      return null;
    }
  }

  Future<void> _runFetch(Future<List<MealModel>> Function() action) async {
    _status = ExploreListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await action();
      _status = ExploreListStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      _status = ExploreListStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  /// Thử lại lần chọn lọc gần nhất — dùng cho nút "Thử lại" ở ErrorView.
  Future<void> retryLastSelection() async {
    final value = _selectedValue;
    if (value != null) await selectValue(value);
  }
}
