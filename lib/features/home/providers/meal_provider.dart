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
  String? _selectedCategory;
  List<String> _categories = const [];
  final List<String> _searchHistory = [];

  Timer? _debounceTimer;

  MealListStatus get status => _status;
  List<MealModel> get meals => _meals;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == MealListStatus.loading;

  String get searchKeyword => _searchKeyword;
  String? get selectedCategory => _selectedCategory;
  List<String> get categories => _categories;
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  Future<void> fetchDefaultMeals() async {
    _debounceTimer?.cancel();
    _searchKeyword = '';
    _selectedCategory = null;
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
    // (đề xuất ở BUSINESS_FLOW.md mục Search & Filter).
    if (trimmed.isEmpty) {
      _selectedCategory = null;
      await _runFetch(() => _repository.getDefaultMeals());
      return;
    }

    _selectedCategory = null;
    await _runFetch(() => _repository.searchMeals(trimmed));

    // [History] Chỉ lưu lại từ khóa khi tìm kiếm thành công.
    if (_status == MealListStatus.success) {
      _addToHistory(trimmed);
    }
  }

  /// [Filter] Chọn/bỏ chọn danh mục — tự xóa từ khóa search đang có, vì
  /// TheMealDB không hỗ trợ kết hợp cả hai điều kiện trong 1 request
  /// (BUSINESS_FLOW.md, đề xuất bổ sung #1).
  Future<void> selectCategory(String? category) async {
    _debounceTimer?.cancel();
    _searchKeyword = '';
    _selectedCategory = category;

    if (category == null) {
      await _runFetch(() => _repository.getDefaultMeals());
      return;
    }
    await _runFetch(() => _repository.filterByCategory(category));
  }

  /// [Suggestion] Nạp danh sách danh mục thật từ TheMealDB — dùng làm chip lọc
  /// và một phần nguồn gợi ý.
  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } on AppException {
      // Danh mục chỉ là gợi ý phụ trợ — lỗi tải danh mục không nên chặn màn
      // hình chính, nên không set _status = error ở đây.
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
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
