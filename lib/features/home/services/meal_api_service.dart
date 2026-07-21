import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/api_exception.dart';
import '../../../core/network/api_client.dart';
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

  /// Gom xử lý request + map lỗi về AppException (đã chuẩn hóa qua ErrorInterceptor
  /// của ApiClient) — tránh lặp try-catch giống hệt nhau ở cả 4 method trên.
  Future<Map<String, dynamic>> _get(
    String path, {
    required Map<String, dynamic> queryParameters,
  }) async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? const {};
    } on DioException catch (e) {
      final mapped = e.error;
      if (mapped is AppException) throw mapped;
      throw const UnknownException('Đã xảy ra lỗi không xác định, vui lòng thử lại.');
    }
  }
}
