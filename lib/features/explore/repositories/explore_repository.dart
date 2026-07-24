import '../../home/models/meal_model.dart';
import '../models/meal_category_model.dart';

/// Hợp đồng cho ExploreProvider — gom các endpoint TheMealDB phục vụ tab Khám
/// phá (ngẫu nhiên, danh mục kèm ảnh, lọc theo vùng/nguyên liệu). Tách khỏi
/// HomeRepository để state của Home và Explore độc lập, không lẫn nhau.
abstract class ExploreRepository {
  Future<MealModel?> getRandomMeal();
  Future<List<MealCategoryModel>> getCategories();
  Future<List<String>> getAreas();
  Future<List<String>> getIngredients();
  Future<List<MealModel>> filterByCategory(String category);
  Future<List<MealModel>> filterByArea(String area);
  Future<List<MealModel>> filterByIngredient(String ingredient);
}
