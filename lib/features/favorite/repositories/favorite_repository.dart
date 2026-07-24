import '../models/favorite_meal_model.dart';

/// Hợp đồng mà FavoriteProvider (Phase 8) sẽ gọi — không biết gì về Firestore
/// hay cache nội bộ bên dưới (Dependency Inversion, PROJECT_GUIDELINES.md mục SOLID).
abstract class FavoriteRepository {
  /// Lắng nghe real-time toàn bộ danh sách yêu thích (FR-FAV-06).
  Stream<List<FavoriteMealModel>> watchFavorites(String uid);

  /// Trạng thái yêu thích của 1 món — dùng ở Meal Detail.
  Future<FavoriteMealModel?> getFavoriteStatus(String uid, String idMeal);

  /// Thêm mới (BR-02: idempotent, không tạo trùng vì dùng idMeal làm Document ID).
  Future<void> addFavorite({
    required String uid,
    required String idMeal,
    required String mealName,
    required String mealThumbnail,
  });

  /// Bỏ yêu thích — idempotent (BR-02).
  Future<void> removeFavorite(String uid, String idMeal);

  /// Toggle an toàn dưới Firestore Transaction (tránh race condition khi bấm
  /// nhanh liên tục). Trả về true nếu kết quả cuối là "đã lưu".
  Future<bool> toggleFavorite({
    required String uid,
    required String idMeal,
    required String mealName,
    required String mealThumbnail,
  });

  /// Cập nhật ghi chú cá nhân.
  Future<void> updateNote(String uid, String idMeal, String note);
}
