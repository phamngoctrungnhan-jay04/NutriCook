import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Log gọn từng request/response/error qua `debugPrint` (tự loại bỏ ở release
/// build, theo PROJECT_GUIDELINES.md mục Logging Rules) — không log header/body
/// để tránh thói quen log dữ liệu nhạy cảm khi có thêm API khác sau này.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[ApiClient] → ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    debugPrint('[ApiClient] ← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[ApiClient] ✗ ${err.type} ${err.requestOptions.uri}: ${err.message}');
    handler.next(err);
  }
}
