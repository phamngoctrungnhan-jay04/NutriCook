/// Request DTO cho "Quên mật khẩu" — chỉ cần email (khác
/// AuthCredentialsRequestDto vì không có password ở bước này).
class ForgotPasswordRequestDto {
  const ForgotPasswordRequestDto({required this.email});

  final String email;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  List<String> validate() {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return ['Email không được để trống.'];
    }
    if (!_emailPattern.hasMatch(trimmedEmail)) {
      return ['Email không đúng định dạng.'];
    }
    return const [];
  }

  String get trimmedEmail => email.trim();
}
