import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper mỏng quanh SharedPreferences — tập trung hết thao tác key thô ở
/// đây, các Store khác chỉ gọi qua method có kiểu dữ liệu rõ ràng.
class PreferencesService {
  Future<List<String>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key) ?? const [];
  }

  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
