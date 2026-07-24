import 'package:dio/dio.dart';

import '../../errors/api_exception.dart';

/// Map lỗi Dio gốc (DioExceptionType) sang AppException chuẩn hóa, gắn vào
/// `DioException.error` — để Service (Phase 4) chỉ cần bắt DioException rồi đọc
/// `e.error as AppException` thay vì tự đoán ý nghĩa từng DioExceptionType.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _mapError(err)));
  }

  AppException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException('Kết nối quá thời gian chờ, vui lòng thử lại.');
      case DioExceptionType.connectionError:
        return const NetworkException(
          'Không thể kết nối mạng, vui lòng kiểm tra Wi-Fi/dữ liệu di động.',
        );
      case DioExceptionType.badResponse:
        return ApiException(
          'Máy chủ trả về lỗi, vui lòng thử lại sau.',
          statusCode: err.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return const UnknownException('Yêu cầu đã bị hủy.');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const UnknownException('Đã xảy ra lỗi không xác định, vui lòng thử lại.');
    }
  }
}
