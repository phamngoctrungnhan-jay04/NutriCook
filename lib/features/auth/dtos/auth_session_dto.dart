/// Response DTO cho "Get Auth Session" (API_DESIGN.md mục Authentication #4).
/// Mapping Rule: dựng trực tiếp từ giá trị `FirebaseAuth.currentUser` (hoặc từ
/// callback `authStateChanges()`) ở AuthService (Phase 4) — không có JSON gốc.
class AuthSessionDto {
  const AuthSessionDto({required this.isAuthenticated, this.uid});

  final bool isAuthenticated;
  final String? uid;

  factory AuthSessionDto.authenticated(String uid) =>
      AuthSessionDto(isAuthenticated: true, uid: uid);

  factory AuthSessionDto.unauthenticated() =>
      const AuthSessionDto(isAuthenticated: false, uid: null);
}
