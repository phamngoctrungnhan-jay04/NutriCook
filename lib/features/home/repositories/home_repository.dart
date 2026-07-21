import '../models/meal_model.dart';

/// Hợp đồng mà MealProvider gọi. Hiện là pass-through mỏng qua MealApiService
/// (Home chỉ có 1 nguồn dữ liệu, không cần điều phối/Transaction) — tạo để
/// nhất quán với FavoriteRepository và làm điểm nối sẵn nếu sau này Home cần
/// thêm nguồn dữ liệu khác.
abstract class HomeRepository {
  Future<List<MealModel>> getDefaultMeals();
  Future<List<MealModel>> searchMeals(String keyword);
  Future<List<MealModel>> filterByCategory(String category);
  Future<MealModel?> getMealDetail(String idMeal);
  Future<List<String>> getCategories();
}
