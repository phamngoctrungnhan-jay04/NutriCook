import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../core/errors/auth_exception.dart';
import '../../profile/models/user_profile_model.dart';
import '../dtos/auth_credentials_request_dto.dart';
import '../dtos/auth_session_dto.dart';
import '../dtos/forgot_password_request_dto.dart';

/// Service duy nhất chạm trực tiếp FirebaseAuth SDK (và Firestore cho bước tạo
/// hồ sơ ban đầu khi Register). Có [login], [register], [logout] — session-stream
/// (Splash) vẫn chưa triển khai.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  Future<AuthSessionDto> login(AuthCredentialsRequestDto credentials) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: credentials.email.trim(),
        password: credentials.password,
      );
      final uid = result.user?.uid;
      if (uid == null) throw const AuthUnknownException();
      return AuthSessionDto.authenticated(uid);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<AuthSessionDto> register(AuthCredentialsRequestDto credentials) async {
    try {
      final email = credentials.email.trim();
      final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: credentials.password,
      );
      final uid = result.user?.uid;
      if (uid == null) throw const AuthUnknownException();

      await _createInitialProfile(uid: uid, email: email);

      return AuthSessionDto.authenticated(uid);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  Future<void> logout() => _firebaseAuth.signOut();

  /// Gửi email chứa link đặt lại mật khẩu — cơ chế native của Firebase Auth,
  /// không có khái niệm OTP. Việc đặt mật khẩu mới diễn ra trên trang web do
  /// Firebase tự host khi người dùng bấm link, không phải trong app.
  Future<void> sendPasswordResetEmail(ForgotPasswordRequestDto request) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: request.trimmedEmail);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e);
    }
  }

  /// Tạo document `users/{uid}` ban đầu (DATABASE_DESIGN.md mục 3.1). Không
  /// throw ra ngoài nếu lỗi — tài khoản Auth đã tạo thành công, không nên coi
  /// Register là thất bại chỉ vì Firestore lỗi tạm thời (DATABASE_DESIGN.md
  /// mục 11: sẽ cần bù trừ ở lần đăng nhập kế tiếp, chưa triển khai ở bước này).
  Future<void> _createInitialProfile({required String uid, required String email}) async {
    final now = DateTime.now();
    final profile = UserProfileModel(uid: uid, email: email, createdAt: now, updatedAt: now);
    try {
      await _firestore.collection('users').doc(uid).set(profile.toMap());
    } catch (e) {
      debugPrint('[AuthService] Failed to create initial profile for $uid: $e');
    }
  }

  AuthException _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const AuthNetworkException();
      default:
        return const AuthUnknownException();
    }
  }
}
