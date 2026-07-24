import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../custom_recipe/repositories/custom_recipe_repository.dart';
import '../../../core/errors/api_exception.dart';
import '../../favorite/repositories/favorite_repository.dart';
import '../../home/models/meal_model.dart';
import '../../home/repositories/home_repository.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum MealDetailStatus { idle, loading, success, error }

/// ViewModel cho Meal Detail — dùng lại HomeRepository (fetch chi tiết) và
/// FavoriteRepository (trạng thái/toggle yêu thích), không có Service/Repository
/// riêng cho module này (đúng SYSTEM_ARCHITECTURE.md, module chỉ có providers/screens).
class MealDetailProvider extends ChangeNotifier {
  MealDetailProvider({
    required HomeRepository homeRepository,
    required FavoriteRepository favoriteRepository,
    CustomRecipeRepository? customRecipeRepository,
    FirebaseAuth? firebaseAuth,
  })  : _homeRepository = homeRepository,
        _favoriteRepository = favoriteRepository,
        _customRecipeRepository = customRecipeRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final HomeRepository _homeRepository;
  final FavoriteRepository _favoriteRepository;
  final CustomRecipeRepository? _customRecipeRepository;
  final FirebaseAuth _firebaseAuth;

  MealDetailStatus _status = MealDetailStatus.idle;
  MealModel? _meal;
  String? _errorMessage;
  bool _isFavorited = false;
  bool _isTogglingFavorite = false;

  MealDetailStatus get status => _status;
  MealModel? get meal => _meal;
  String? get errorMessage => _errorMessage;
  bool get isFavorited => _isFavorited;
  bool get isTogglingFavorite => _isTogglingFavorite;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  Future<void> loadMeal(String idMeal) async {
    _status = MealDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      MealModel? meal;
      if (idMeal.startsWith('custom_') && _customRecipeRepository != null) {
        final uid = _uid;
        if (uid != null) {
          meal = await _customRecipeRepository.getCustomRecipe(uid, idMeal);
        }
      } else {
        meal = await _homeRepository.getMealDetail(idMeal);
      }

      if (meal == null) {
        _status = MealDetailStatus.error;
        _errorMessage = 'Recipe not found.';
        notifyListeners();
        return;
      }
      _meal = meal;
      _status = MealDetailStatus.success;
      notifyListeners();
      if (!idMeal.startsWith('custom_')) {
        await _loadFavoriteStatus(idMeal);
      }
    } on AppException catch (e) {
      _status = MealDetailStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> _loadFavoriteStatus(String idMeal) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      final favorite = await _favoriteRepository.getFavoriteStatus(uid, idMeal);
      _isFavorited = favorite != null;
      notifyListeners();
    } catch (e) {
      // FavoriteRepository chưa có exception chuẩn hóa riêng — trạng thái yêu
      // thích chỉ là phụ, lỗi ở đây không nên chặn màn hình chính.
      debugPrint('[MealDetailProvider] Failed to load favorite status: $e');
    }
  }

  Future<void> toggleFavorite() async {
    final uid = _uid;
    final meal = _meal;
    if (uid == null || meal == null || _isTogglingFavorite) return;

    _isTogglingFavorite = true;
    notifyListeners();

    try {
      final result = await _favoriteRepository.toggleFavorite(
        uid: uid,
        idMeal: meal.idMeal,
        mealName: meal.name,
        mealThumbnail: meal.thumbnailUrl,
      );
      _isFavorited = result;
    } catch (e) {
      debugPrint('[MealDetailProvider] Failed to toggle favorite: $e');
    } finally {
      _isTogglingFavorite = false;
      notifyListeners();
    }
  }
}
