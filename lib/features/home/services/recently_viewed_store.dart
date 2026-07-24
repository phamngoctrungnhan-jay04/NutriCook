import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_service.dart';
import '../models/recently_viewed_meal.dart';

/// Lưu danh sách món đã xem gần đây qua Hive — tự giới hạn số lượng
/// ([maxEntries]) thay vì hết hạn theo thời gian (TTL), đúng bản chất "lịch
/// sử" chứ không phải cache hiệu năng. Store này CHƯA được nối vào
/// MealDetailProvider (chờ bước wiring UI riêng).
class RecentlyViewedStore {
  static const int maxEntries = 20;

  Box<Map> get _box => Hive.box<Map>(HiveService.recentlyViewedBoxName);

  /// Sắp xếp mới nhất trước.
  List<RecentlyViewedMeal> getAll() {
    final entries = _box.values.map(RecentlyViewedMeal.fromMap).toList();
    entries.sort((a, b) => b.viewedAt.compareTo(a.viewedAt));
    return entries;
  }

  /// Dùng [idMeal] làm key — xem lại 1 món chỉ cập nhật thời gian, không tạo
  /// bản ghi trùng.
  Future<void> addMeal({
    required String idMeal,
    required String name,
    required String thumbnailUrl,
  }) async {
    final entry = RecentlyViewedMeal(
      idMeal: idMeal,
      name: name,
      thumbnailUrl: thumbnailUrl,
      viewedAt: DateTime.now(),
    );
    await _box.put(idMeal, entry.toMap());

    if (_box.length > maxEntries) {
      final excess = getAll().skip(maxEntries).map((e) => e.idMeal);
      await _box.deleteAll(excess);
    }
  }

  Future<void> clear() => _box.clear();
}
