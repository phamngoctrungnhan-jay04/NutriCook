import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
import '../../explore/models/meal_category_model.dart';
import '../models/meal_model.dart';

/// Service duy nhất chạm TheMealDB — dùng chung cho Home, Search & Filter,
/// Meal Detail (theo SYSTEM_ARCHITECTURE.md, vị trí file này phục vụ cả 3 module).
class MealApiService {
  MealApiService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: ApiConstants.theMealDbBaseUrl);

  final ApiClient _apiClient;

  /// Danh sách mặc định cho Home (FR-HOME-01) — món bắt đầu bằng chữ 'b'.
  Future<List<MealModel>> getDefaultMeals() async {
    final data = await _get(ApiConstants.searchEndpoint, queryParameters: {'f': 'b'});
    return MealModel.listFromResponse(data);
  }

  Future<List<MealModel>> searchMeals(String keyword) async {
    final data = await _get(ApiConstants.searchEndpoint, queryParameters: {'s': keyword});
    return MealModel.listFromResponse(data);
  }

  Future<List<MealModel>> filterByCategory(String category) async {
    final data = await _get(ApiConstants.filterEndpoint, queryParameters: {'c': category});
    return MealModel.listFromResponse(data);
  }

  Future<MealModel?> getMealDetail(String idMeal) async {
    final data = await _get(ApiConstants.lookupEndpoint, queryParameters: {'i': idMeal});
    final meals = MealModel.listFromResponse(data);
    return meals.isEmpty ? null : meals.first;
  }

  /// 1 món ngẫu nhiên (`random.php`) — response đã ở dạng chi tiết đầy đủ, nhưng
  /// ở đây chỉ cần lấy `idMeal` để điều hướng sang Meal Detail (tái dùng lookup).
  Future<MealModel?> getRandomMeal() async {
    final data = await _get(ApiConstants.randomEndpoint, queryParameters: const {});
    final meals = MealModel.listFromResponse(data);
    return meals.isEmpty ? null : meals.first;
  }

  Future<List<MealModel>> filterByArea(String area) async {
    final data = await _get(ApiConstants.filterEndpoint, queryParameters: {'a': area});
    return MealModel.listFromResponse(data);
  }

  Future<List<MealModel>> filterByIngredient(String ingredient) async {
    final data = await _get(ApiConstants.filterEndpoint, queryParameters: {'i': ingredient});
    return MealModel.listFromResponse(data);
  }

  /// Danh sách vùng ẩm thực (`list.php?a=list`) — dùng làm chip lọc theo Area.
  Future<List<String>> getAreas() async {
    final data = await _get(ApiConstants.categoryListEndpoint, queryParameters: {'a': 'list'});
    return _parseStringList(data, 'strArea');
  }

  /// Danh sách nguyên liệu (`list.php?i=list`) — dùng làm chip lọc theo Ingredient.
  Future<List<String>> getIngredients() async {
    final data = await _get(ApiConstants.categoryListEndpoint, queryParameters: {'i': 'list'});
    return _parseStringList(data, 'strIngredient');
  }

  /// Danh mục kèm ảnh + mô tả (`categories.php`) — giàu thông tin hơn `list.php?c=list`.
  Future<List<MealCategoryModel>> getCategoriesDetailed() async {
    final data = await _get(ApiConstants.categoriesEndpoint, queryParameters: const {});
    return MealCategoryModel.listFromResponse(data);
  }

  /// Gom parse các endpoint `list.php` trả `{ "meals": [{ "<field>": ... }] }`.
  List<String> _parseStringList(Map<String, dynamic> data, String field) {
    final rawList = data['meals'] as List<dynamic>?;
    if (rawList == null) return const [];
    return rawList
        .map((item) => (item as Map<String, dynamic>)[field] as String? ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  /// Danh sách danh mục thật từ TheMealDB — dùng làm chip lọc (Filter) và một
  /// phần nguồn gợi ý (Suggestion), không tự bịa dữ liệu.
  Future<List<String>> getCategories() async {
    final data = await _get(ApiConstants.categoryListEndpoint, queryParameters: {'c': 'list'});
    final rawList = data['meals'] as List<dynamic>?;
    if (rawList == null) return const [];
    return rawList
        .map((item) => (item as Map<String, dynamic>)['strCategory'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw const ApiException('Invalid response format.');
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is AppException) throw mapped;
      throw const UnknownException('An unknown error occurred, please try again.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw UnknownException('System error: ${e.toString()}');
    }
  }
}
