/// Response DTO cho "Get Favorite Status" (API_DESIGN.md mục Favorite #3) —
/// dùng ở Meal Detail để hiển thị đúng trạng thái icon trái tim.
class FavoriteStatusDto {
  const FavoriteStatusDto({required this.isFavorited, this.note});

  final bool isFavorited;
  final String? note;

  /// Mapping Rule: [map] là `DocumentSnapshot.data()` của
  /// `users/{uid}/favorites/{idMeal}` — null nghĩa là document chưa tồn tại
  /// (chưa được yêu thích), khác với lỗi.
  factory FavoriteStatusDto.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FavoriteStatusDto(isFavorited: false);
    return FavoriteStatusDto(isFavorited: true, note: map['note'] as String?);
  }
}
