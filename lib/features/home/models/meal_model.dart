/// Một nguyên liệu + định lượng, trích từ các field `strIngredientN`/`strMeasureN`
/// của TheMealDB (N = 1..20). Class phụ nhỏ, gắn chặt với MealModel.
class MealIngredient {
  const MealIngredient({required this.name, required this.measure});

  final String name;
  final String measure;
}

/// Món ăn lấy từ TheMealDB. Dùng chung cho cả response danh sách (search/filter —
/// chỉ có id/tên/ảnh) lẫn response chi tiết (lookup — có thêm nguyên liệu/hướng dẫn),
/// nên mọi field ngoài id/tên/ảnh đều là optional.
class MealModel {
  const MealModel({
    required this.idMeal,
    required this.name,
    required this.thumbnailUrl,
    this.category,
    this.instructions,
    this.ingredients = const [],
  });

  final String idMeal;
  final String name;
  final String thumbnailUrl;
  final String? category;
  final String? instructions;
  final List<MealIngredient> ingredients;

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      idMeal: json['idMeal'] as String? ?? '',
      name: json['strMeal'] as String? ?? '',
      thumbnailUrl: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: _parseIngredients(json),
    );
  }

  static List<MealIngredient> _parseIngredients(Map<String, dynamic> json) {
    final ingredients = <MealIngredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = json['strIngredient$i'] as String?;
      if (name == null || name.trim().isEmpty) continue;
      final measure = json['strMeasure$i'] as String?;
      ingredients.add(MealIngredient(name: name.trim(), measure: (measure ?? '').trim()));
    }
    return ingredients;
  }

  /// Parse response `{ "meals": [...] }` từ TheMealDB.
  ///
  /// TheMealDB trả `meals: null` khi không có kết quả (thay vì mảng rỗng) — luôn
  /// map về danh sách rỗng ở đây để tầng trên không phải tự kiểm tra null (BR-07).
  static List<MealModel> listFromResponse(Map<String, dynamic> response) {
    final rawList = response['meals'] as List<dynamic>?;
    if (rawList == null) return const [];
    return rawList
        .map((item) => MealModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
