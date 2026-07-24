/// Danh mục món ăn từ endpoint `categories.php` của TheMealDB — khác với
/// `list.php?c=list` (chỉ trả tên), endpoint này có kèm ảnh minh họa + mô tả.
class MealCategoryModel {
  const MealCategoryModel({
    required this.idCategory,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  final String idCategory;
  final String name;
  final String thumbnailUrl;
  final String description;

  factory MealCategoryModel.fromJson(Map<String, dynamic> json) {
    return MealCategoryModel(
      idCategory: json['idCategory'] as String? ?? '',
      name: json['strCategory'] as String? ?? '',
      thumbnailUrl: json['strCategoryThumb'] as String? ?? '',
      description: json['strCategoryDescription'] as String? ?? '',
    );
  }

  /// Parse response `{ "categories": [...] }` từ TheMealDB — trả về danh sách
  /// rỗng nếu thiếu key (tầng trên không phải tự kiểm tra null).
  static List<MealCategoryModel> listFromResponse(Map<String, dynamic> response) {
    final rawList = response['categories'] as List<dynamic>?;
    if (rawList == null) return const [];
    return rawList
        .map((item) => MealCategoryModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
