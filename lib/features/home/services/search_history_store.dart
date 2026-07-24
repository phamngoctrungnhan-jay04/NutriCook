import '../../../core/storage/preferences_service.dart';

/// Lịch sử tìm kiếm PERSISTENT (khác bản trong-bộ-nhớ hiện có ở MealProvider,
/// mất khi tắt app) — lưu qua SharedPreferences. Store này CHƯA được nối vào
/// MealProvider (chờ bước wiring UI riêng, không thuộc phạm vi lần này).
class SearchHistoryStore {
  SearchHistoryStore({PreferencesService? preferencesService})
      : _preferences = preferencesService ?? PreferencesService();

  final PreferencesService _preferences;

  static const String _key = 'search_history';
  static const int maxEntries = 10;

  Future<List<String>> getHistory() => _preferences.getStringList(_key);

  Future<void> addKeyword(String keyword) async {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    final history = await getHistory();
    history.remove(trimmed);
    history.insert(0, trimmed);
    if (history.length > maxEntries) {
      history.removeRange(maxEntries, history.length);
    }
    await _preferences.setStringList(_key, history);
  }

  Future<void> clear() => _preferences.remove(_key);
}
