/// Exception chuẩn hóa cho Firebase Authentication — riêng biệt với AppException
/// (dùng cho Dio/REST ở api_exception.dart), theo Error Flow ở
/// SYSTEM_ARCHITECTURE.md mục 11 (liệt kê AuthException là một nhóm lỗi riêng).
sealed class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('Email hoặc mật khẩu không đúng.');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('Tài khoản không tồn tại.');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException() : super('Email này đã được sử dụng để đăng ký.');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Mật khẩu quá yếu, vui lòng chọn mật khẩu khác.');
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super('Bạn đã thử quá nhiều lần, vui lòng thử lại sau.');
}

class AuthNetworkException extends AuthException {
  const AuthNetworkException()
      : super('Không thể kết nối mạng, vui lòng kiểm tra kết nối.');
}

class AuthUnknownException extends AuthException {
  const AuthUnknownException()
      : super('Đã xảy ra lỗi không xác định, vui lòng thử lại.');
}
