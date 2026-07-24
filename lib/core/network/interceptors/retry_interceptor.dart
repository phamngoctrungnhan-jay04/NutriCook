import 'package:dio/dio.dart';

/// Tự động thử lại request khi gặp lỗi mạng tạm thời (timeout/mất kết nối),
/// tối đa [maxRetries] lần, có backoff tăng dần theo số giây — vì TheMealDB là
/// dịch vụ miễn phí không có SLA, dễ chập chờn (theo PROJECT_REQUIREMENTS.md
/// mục Constraints).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.maxRetries = 2});

  final Dio dio;
  final int maxRetries;

  static const String _retryCountKey = 'retry_count';

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.transformTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = (requestOptions.extra[_retryCountKey] as int?) ?? 0;

    if (!_isRetryable(err) || retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    final nextAttempt = retryCount + 1;
    await Future<void>.delayed(Duration(seconds: nextAttempt));
    requestOptions.extra[_retryCountKey] = nextAttempt;

    try {
      final response = await dio.fetch<dynamic>(requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
