/// Request DTO dùng chung cho Register và Login (API_DESIGN.md: 2 endpoint này
/// nhận request giống hệt nhau — {email, password}).
class AuthCredentialsRequestDto {
  const AuthCredentialsRequestDto({required this.email, required this.password});

  final String email;
  final String password;

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Validation theo BR-05: email đúng định dạng, password ≥ 6 ký tự.
  List<String> validate() {
    final errors = <String>[];

    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      errors.add('Email không được để trống.');
    } else if (!_emailPattern.hasMatch(trimmedEmail)) {
      errors.add('Email không đúng định dạng.');
    }

    if (password.isEmpty) {
      errors.add('Mật khẩu không được để trống.');
    } else if (password.length < 6) {
      errors.add('Mật khẩu phải có ít nhất 6 ký tự.');
    }

    return errors;
  }

  /// Mapping Rule: gửi thẳng làm tham số cho FirebaseAuth
  /// (createUserWithEmailAndPassword/signInWithEmailAndPassword) ở Phase 4.
  Map<String, String> toMap() => {'email': email.trim(), 'password': password};
}
