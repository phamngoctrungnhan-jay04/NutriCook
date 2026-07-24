import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../../custom_recipe/repositories/custom_recipe_repository.dart';
import '../../home/models/meal_model.dart';
import '../../home/repositories/home_repository.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum CategoryMealsStatus { idle, loading, success, error }

/// ViewModel cho trang "món ăn theo danh mục" — tạo mới mỗi lần vào 1 danh mục
/// (per-route, giống MealDetailProvider). Dùng lại HomeRepository.filterByCategory
/// (đã có sẵn), không cần plumbing mới.
class CategoryMealsProvider extends ChangeNotifier {
  CategoryMealsProvider({
    required HomeRepository homeRepository,
    CustomRecipeRepository? customRecipeRepository,
    FirebaseAuth? firebaseAuth,
  })  : _repository = homeRepository,
        _customRecipeRepository = customRecipeRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final HomeRepository _repository;
  final CustomRecipeRepository? _customRecipeRepository;
  final FirebaseAuth _firebaseAuth;

  CategoryMealsStatus _status = CategoryMealsStatus.idle;
  List<MealModel> _meals = const [];
  String? _errorMessage;

  CategoryMealsStatus get status => _status;
  List<MealModel> get meals => _meals;
  String? get errorMessage => _errorMessage;

  Future<void> loadMeals(String category) async {
    _status = CategoryMealsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final apiMeals = await _repository.filterByCategory(category);

      List<MealModel> customMeals = [];
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid != null && _customRecipeRepository != null) {
        try {
          final allCustom = await _customRecipeRepository.watchCustomRecipes(uid).first;
          customMeals = allCustom
              .where((m) => m.category?.toLowerCase() == category.toLowerCase())
              .toList();
        } catch (e) {
          debugPrint('[CategoryMealsProvider] Custom recipes fetch error: $e');
        }
      }

      _meals = [...customMeals, ...apiMeals];
      _status = CategoryMealsStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      _status = CategoryMealsStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    }
  }
}
