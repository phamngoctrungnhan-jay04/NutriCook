import 'package:cloud_firestore/cloud_firestore.dart';

/// Món ăn yêu thích, lưu tại `users/{uid}/favorites/{idMeal}` (DATABASE_DESIGN.md
/// mục 3.2). `idMeal` vừa là Document ID (nguồn xác thực), vừa được lưu lặp lại
/// trong field để tiện truy vấn/export.
class FavoriteMealModel {
  const FavoriteMealModel({
    required this.idMeal,
    required this.mealName,
    required this.mealThumbnail,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String idMeal;
  final String mealName;
  final String mealThumbnail;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// [idMeal] truyền riêng vì đây là Document ID (nguồn xác thực chính theo
  /// DATABASE_DESIGN.md mục 4), không chỉ đọc từ field bên trong map.
  factory FavoriteMealModel.fromMap(String idMeal, Map<String, dynamic> map) {
    return FavoriteMealModel(
      idMeal: idMeal,
      mealName: map['mealName'] as String? ?? '',
      mealThumbnail: map['mealThumbnail'] as String? ?? '',
      note: map['note'] as String? ?? '',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idMeal': idMeal,
      'mealName': mealName,
      'mealThumbnail': mealThumbnail,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  FavoriteMealModel copyWith({String? note, DateTime? updatedAt}) {
    return FavoriteMealModel(
      idMeal: idMeal,
      mealName: mealName,
      mealThumbnail: mealThumbnail,
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
