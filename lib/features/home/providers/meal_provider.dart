import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/errors/api_exception.dart';
import '../models/meal_model.dart';
import '../repositories/home_repository.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum MealListStatus { idle, loading, success, error }

/// ViewModel dùng chung cho Home + Search & Filter (SYSTEM_ARCHITECTURE.md mục 9:
/// 1 Provider quản lý cả 3 module này, không tách Provider riêng).
class MealProvider extends ChangeNotifier {
  MealProvider({required HomeRepository homeRepository}) : _repository = homeRepository;

  final HomeRepository _repository;

  static const Duration _debounceDuration = Duration(milliseconds: 400);
  static const int _maxHistoryLength = 10;

  MealListStatus _status = MealListStatus.idle;
  List<MealModel> _meals = const [];
  String? _errorMessage;

  String _searchKeyword = '';
  Set<String> _selectedIngredients = {};
  List<String> _ingredients = const [];
  final List<String> _searchHistory = [];

  Timer? _debounceTimer;

  MealListStatus get status => _status;
  List<MealModel> get meals => _meals;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MealListStatus.loading;

  String get searchKeyword => _searchKeyword;
  Set<String> get selectedIngredients => _selectedIngredients;
  List<String> get ingredients => _ingredients;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  Future<void> fetchDefaultMeals() async {
    _debounceTimer?.cancel();
    _searchKeyword = '';
    _selectedIngredients = {};
    await _runFetch(() => _repository.getDefaultMeals());
  }

  /// [Search] Gọi mỗi khi người dùng gõ vào ô tìm kiếm.
  /// [Debounce] Chỉ thực sự gọi API sau khi ngừng gõ 400ms, tránh gọi liên tục
  /// mỗi ký tự.
  void onSearchChanged(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () => _performSearch(keyword));
  }

  /// Tìm kiếm ngay lập tức, bỏ qua debounce — dùng khi người dùng bấm trực tiếp
  /// vào 1 gợi ý (Suggestion) thay vì tự gõ.
  Future<void> searchImmediately(String keyword) async {
    _debounceTimer?.cancel();
    _searchKeyword = keyword;
    notifyListeners();
    await _performSearch(keyword);
  }

  Future<void> _performSearch(String keyword) async {
    final trimmed = keyword.trim();

    // Không gọi API với từ khóa rỗng — quay về danh sách mặc định
    if (trimmed.isEmpty) {
      _selectedIngredients = {};
      await _runFetch(() => _repository.getDefaultMeals());
      return;
    }

    _selectedIngredients = {};
    await _runFetch(() => _repository.searchMeals(trimmed));

    // [History] Chỉ lưu lại từ khóa khi tìm kiếm thành công.
    if (_status == MealListStatus.success) {
      _addToHistory(trimmed);
    }
  }

  /// [Filter] Áp dụng bộ lọc nhiều nguyên liệu — tự xóa từ khóa search đang có.
  /// Lọc nguyên liệu sử dụng phép GIAO (intersection) — món ăn phải chứa tất cả nguyên liệu lọc.
  Future<void> applyIngredients(Set<String> ingredients) async {
    _debounceTimer?.cancel();
    _searchKeyword = '';
    _selectedIngredients = ingredients;

    if (ingredients.isEmpty) {
      await _runFetch(() => _repository.getDefaultMeals());
      return;
    }
    await _runFetch(() => _fetchMergedIngredients(ingredients));
  }

  /// Gọi filterByIngredient cho từng nguyên liệu (song song), tìm các ID chung (GIAO - AND).
  Future<List<MealModel>> _fetchMergedIngredients(Set<String> ingredients) async {
    final lists = await Future.wait(
      ingredients.map((ingredient) => _repository.filterByIngredient(ingredient)),
    );
    if (lists.isEmpty) return const [];

    var commonIds = lists.first.map((m) => m.idMeal).toSet();
    for (var i = 1; i < lists.length; i++) {
      final currentIds = lists[i].map((m) => m.idMeal).toSet();
      commonIds = commonIds.intersection(currentIds);
    }

    final seen = <String>{};
    final merged = <MealModel>[];
    for (final list in lists) {
      for (final meal in list) {
        if (commonIds.contains(meal.idMeal) && seen.add(meal.idMeal)) {
          merged.add(meal);
        }
      }
    }
    return merged;
  }

  /// [Suggestion] Nạp danh sách nguyên liệu thật từ TheMealDB — dùng làm chip lọc.
  Future<void> loadIngredients() async {
    try {
      _ingredients = await _repository.getIngredients();
      notifyListeners();
    } catch (e) {
      // Lỗi tải nguyên liệu phụ trợ không chặn màn hình chính.
    }
  }

  /// [History] Xóa toàn bộ lịch sử tìm kiếm (chỉ tồn tại trong phiên hiện tại).
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  void _addToHistory(String keyword) {
    _searchHistory.remove(keyword);
    _searchHistory.insert(0, keyword);
    if (_searchHistory.length > _maxHistoryLength) {
      _searchHistory.removeLast();
    }
  }

  Future<void> _runFetch(Future<List<MealModel>> Function() action) async {
    _status = MealListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _meals = await action();
      _status = MealListStatus.success;
      notifyListeners();
    } on AppException catch (e) {
      _status = MealListStatus.error;
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _status = MealListStatus.error;
      _errorMessage = 'An unknown error occurred, please try again later.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
