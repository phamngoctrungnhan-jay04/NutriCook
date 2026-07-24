import 'package:hive_flutter/hive_flutter.dart';

/// Khởi tạo Hive cho toàn app — gọi đúng 1 lần ở main.dart trước runApp().
/// Lưu `Map<String, dynamic>` thô (không dùng TypeAdapter/codegen) để tránh
/// thêm build_runner cho MVP — đơn giản hơn, đủ dùng cho dữ liệu nhỏ.
class HiveService {
  const HiveService._();

  static const String recentlyViewedBoxName = 'recently_viewed_meals';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(recentlyViewedBoxName);
  }
}
