/// App Status Code chuẩn hóa, theo API_DESIGN.md mục "Status Code chuẩn hóa".
/// Service (Phase 4) sẽ map exception gốc (FirebaseAuthException, SocketException...)
/// về đúng 1 trong các mã này, để Provider/UI xử lý nhất quán bất kể nguồn lỗi.
enum ApiStatusCode {
  ok,
  validationError,
  unauthenticated,
  unauthorized,
  notFound,
  conflict,
  networkError,
  serviceUnavailable,
  unknownError,
}

/// Response DTO dùng chung — "vỏ bọc" kết quả mà Service trả về cho Provider,
/// theo API_DESIGN.md mục "Response Format thống nhất".
class ApiResult<T> {
  const ApiResult._({
    required this.isSuccess,
    this.data,
    this.errorCode,
    this.errorMessage,
  });

  factory ApiResult.success(T data) => ApiResult._(isSuccess: true, data: data);

  factory ApiResult.failure(ApiStatusCode code, String message) => ApiResult._(
        isSuccess: false,
        errorCode: code,
        errorMessage: message,
      );

  final bool isSuccess;
  final T? data;
  final ApiStatusCode? errorCode;
  final String? errorMessage;
}
