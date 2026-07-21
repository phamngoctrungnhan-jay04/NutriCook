/// Base URL và endpoint của TheMealDB, theo API_DESIGN.md.
/// API key public `1` đã nằm sẵn trong path, không cần truyền riêng.
class ApiConstants {
  const ApiConstants._();

  static const String theMealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1/';

  static const String searchEndpoint = 'search.php';
  static const String filterEndpoint = 'filter.php';
  static const String lookupEndpoint = 'lookup.php';
  static const String categoryListEndpoint = 'list.php';
}
