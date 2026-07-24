import '../models/favorite_meal_model.dart';

/// Cache TRONG BỘ NHỚ (session-scoped) — KHÔNG lưu xuống đĩa, KHÔNG phải chế độ
/// offline (đã xác nhận ngoài phạm vi MVP ở PROJECT_REQUIREMENTS.md mục Out of
/// Scope). Mục đích duy nhất: tránh chờ round-trip Firestore khi một nơi khác
/// trong cùng phiên app (ví dụ Meal Detail) cần biết ngay "món này đã yêu thích
/// chưa". FavoriteRemoteDataSource luôn là nguồn xác thực duy nhất — cache này
/// chỉ được cập nhật THEO SAU dữ liệu remote, không bao giờ ghi ngược lên Firestore.
class FavoriteLocalDataSource {
  final Map<String, FavoriteMealModel> _cache = {};

  /// Đồng bộ cache theo danh sách mới nhất từ remote — gọi mỗi khi
  /// `watchFavorites()` phát dữ liệu mới.
  void syncFromRemote(List<FavoriteMealModel> favorites) {
    _cache
      ..clear()
      ..addEntries(favorites.map((favorite) => MapEntry(favorite.idMeal, favorite)));
  }

  FavoriteMealModel? getCached(String idMeal) => _cache[idMeal];

  bool isFavorited(String idMeal) => _cache.containsKey(idMeal);

  /// Gọi khi đăng xuất — không để lộ dữ liệu của tài khoản trước sang phiên sau.
  void clear() => _cache.clear();
}
