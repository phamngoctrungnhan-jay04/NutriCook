/// Request DTO cho "Add Favorite" (API_DESIGN.md mục Favorite #1).
///
/// Cố ý KHÔNG có `note/createdAt/updatedAt` như FavoriteMealModel — đây là dữ
/// liệu gửi lúc TẠO MỚI, các field kia sẽ do FirestoreService (Phase 4) tự điền
/// (note mặc định rỗng, timestamp lấy tại thời điểm ghi).
class AddFavoriteRequestDto {
  const AddFavoriteRequestDto({
    required this.idMeal,
    required this.mealName,
    required this.mealThumbnail,
  });

  final String idMeal;
  final String mealName;
  final String mealThumbnail;

  /// Validation theo API_DESIGN.md: idMeal, mealName, mealThumbnail không được rỗng.
  List<String> validate() {
    final errors = <String>[];
    if (idMeal.trim().isEmpty) errors.add('idMeal không được để trống.');
    if (mealName.trim().isEmpty) errors.add('Tên món ăn không được để trống.');
    if (mealThumbnail.trim().isEmpty) errors.add('Ảnh món ăn không được để trống.');
    return errors;
  }

  /// Mapping Rule: dùng làm phần khởi tạo cho FavoriteMealModel trước khi gọi
  /// FirestoreService.set(...) — Service sẽ bổ sung note/createdAt/updatedAt.
  Map<String, dynamic> toMap() => {
        'idMeal': idMeal,
        'mealName': mealName,
        'mealThumbnail': mealThumbnail,
      };
}
