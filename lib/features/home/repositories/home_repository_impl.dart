import '../models/meal_model.dart';
import '../services/meal_api_service.dart';
import 'home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({required MealApiService mealApiService}) : _service = mealApiService;

  final MealApiService _service;

  @override
  Future<List<MealModel>> getDefaultMeals() => _service.getDefaultMeals();

  @override
  Future<List<MealModel>> searchMeals(String keyword) => _service.searchMeals(keyword);

  @override
  Future<List<MealModel>> filterByCategory(String category) =>
      _service.filterByCategory(category);

  @override
  Future<MealModel?> getMealDetail(String idMeal) => _service.getMealDetail(idMeal);

  @override
  Future<List<String>> getCategories() => _service.getCategories();
}
