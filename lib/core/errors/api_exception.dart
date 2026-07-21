/// Exception chuẩn hóa cho tầng gọi REST API (Dio) — theo SYSTEM_ARCHITECTURE.md
/// mục 11 (Error Flow). `AuthException`/`FirestoreException` (cho Firebase) sẽ
/// được thêm ở Phase 4 khi xây AuthService/FirestoreService — không thuộc phạm
/// vi API Client (Dio) này vì Firebase không đi qua Dio.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ApiException extends AppException {
  const ApiException(super.message, {this.statusCode});

  final int? statusCode;
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
