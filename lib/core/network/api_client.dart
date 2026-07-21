import 'package:dio/dio.dart';

import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Dio client dùng chung cho mọi lời gọi REST API (hiện tại chỉ TheMealDB).
///
/// Refresh Token: KHÔNG áp dụng cho client này.
/// - TheMealDB là REST API công khai, dùng chung API key `1` trong URL — không
///   có khái niệm access token/refresh token.
/// - Dữ liệu có xác thực thật của app (Firebase Auth + Cloud Firestore) không đi
///   qua Dio — dùng trực tiếp Firebase SDK, và SDK đó tự động refresh ID token
///   nội bộ, không cần interceptor thủ công ở đây.
/// Nếu tương lai thêm một REST API khác có xác thực, chỉ cần thêm 1 interceptor
/// mới vào danh sách `dio.interceptors` bên dưới, không cần đổi cấu trúc này.
class ApiClient {
  ApiClient({required String baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    dio.interceptors.addAll([
      LoggingInterceptor(),
      RetryInterceptor(dio: dio),
      ErrorInterceptor(),
    ]);
  }

  final Dio dio;
}
