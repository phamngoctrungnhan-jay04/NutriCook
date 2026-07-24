import '../../home/models/meal_model.dart';
import '../../home/services/meal_api_service.dart';
import '../models/meal_category_model.dart';
import 'explore_repository.dart';

/// Pass-through mỏng qua MealApiService (giống HomeRepositoryImpl) — Explore chỉ
/// tiêu thụ TheMealDB, không cần điều phối/Transaction.
class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl({required MealApiService mealApiService})
      : _service = mealApiService;

  final MealApiService _service;

  @override
  Future<MealModel?> getRandomMeal() => _service.getRandomMeal();

  @override
  Future<List<MealCategoryModel>> getCategories() => _service.getCategoriesDetailed();

  @override
  Future<List<String>> getAreas() => _service.getAreas();

  @override
  Future<List<String>> getIngredients() => _service.getIngredients();

  @override
  Future<List<MealModel>> filterByCategory(String category) =>
      _service.filterByCategory(category);

  @override
  Future<List<MealModel>> filterByArea(String area) => _service.filterByArea(area);

  @override
  Future<List<MealModel>> filterByIngredient(String ingredient) =>
      _service.filterByIngredient(ingredient);
}
