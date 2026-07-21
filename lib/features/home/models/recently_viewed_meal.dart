/// Bản ghi "đã xem gần đây" — CHỈ chứa dữ liệu hiển thị rút gọn (id/tên/ảnh),
/// không có nguyên liệu/hướng dẫn — tránh vi phạm BR-07 (không lưu trữ lâu
/// dài toàn bộ nội dung công thức gốc). Đây là dữ liệu hành vi cá nhân, giống
/// tinh thần denormalize của FavoriteMealModel.
class RecentlyViewedMeal {
  const RecentlyViewedMeal({
    required this.idMeal,
    required this.name,
    required this.thumbnailUrl,
    required this.viewedAt,
  });

  final String idMeal;
  final String name;
  final String thumbnailUrl;
  final DateTime viewedAt;

  factory RecentlyViewedMeal.fromMap(Map<dynamic, dynamic> map) {
    return RecentlyViewedMeal(
      idMeal: map['idMeal'] as String? ?? '',
      name: map['name'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
      viewedAt: DateTime.tryParse(map['viewedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMeal': idMeal,
      'name': name,
      'thumbnailUrl': thumbnailUrl,
      'viewedAt': viewedAt.toIso8601String(),
    };
  }
}
