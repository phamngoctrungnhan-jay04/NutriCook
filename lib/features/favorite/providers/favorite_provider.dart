import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../dtos/update_favorite_note_request_dto.dart';
import '../models/favorite_meal_model.dart';
import '../repositories/favorite_repository.dart';

/// Pattern trạng thái thống nhất theo SYSTEM_ARCHITECTURE.md mục 9.
enum FavoriteListStatus { idle, loading, success, error }

/// ViewModel cho màn Favorite — Read (real-time), Update (ghi chú), Delete.
/// Create (toggle yêu thích) đã có sẵn ở MealDetailProvider, không lặp lại ở đây.
class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider({
    required FavoriteRepository favoriteRepository,
    FirebaseAuth? firebaseAuth,
  })  : _repository = favoriteRepository,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _subscribeToFavorites();
  }

  final FavoriteRepository _repository;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription<List<FavoriteMealModel>>? _subscription;

  FavoriteListStatus _status = FavoriteListStatus.idle;
  List<FavoriteMealModel> _favorites = const [];
  String? _errorMessage;

  FavoriteListStatus get status => _status;
  List<FavoriteMealModel> get favorites => _favorites;
  String? get errorMessage => _errorMessage;

  String? get _uid => _firebaseAuth.currentUser?.uid;

  /// [Read] Lắng nghe real-time toàn bộ danh sách yêu thích (FR-FAV-06) — mọi
  /// thay đổi (kể cả từ Meal Detail) tự động phản ánh vào danh sách này.
  void _subscribeToFavorites() {
    final uid = _uid;
    if (uid == null) return;

    _status = FavoriteListStatus.loading;
    notifyListeners();

    _subscription = _repository.watchFavorites(uid).listen(
      (favorites) {
        _favorites = favorites;
        _status = FavoriteListStatus.success;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        _status = FavoriteListStatus.error;
        _errorMessage = 'Không thể tải danh sách yêu thích.';
        notifyListeners();
      },
    );
  }

  /// [Delete] Vuốt để xóa (FR-FAV-03) — idempotent, không cần kiểm tra tồn tại
  /// trước (BR-02).
  Future<void> removeFavorite(String idMeal) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await _repository.removeFavorite(uid, idMeal);
    } catch (e) {
      // FavoriteRepository chưa có exception chuẩn hóa riêng (FirestoreException
      // chưa triển khai) — log lại, UI đã tự cập nhật lạc quan qua Dismissible.
      debugPrint('[FavoriteProvider] Failed to remove favorite: $e');
    }
  }

  /// [Update] Sửa ghi chú cá nhân (FR-FAV-04), validate qua DTO đã có sẵn.
  Future<bool> updateNote(String idMeal, String note) async {
    final uid = _uid;
    if (uid == null) return false;

    final errors = UpdateFavoriteNoteRequestDto(note: note).validate();
    if (errors.isNotEmpty) return false;

    try {
      await _repository.updateNote(uid, idMeal, note);
      return true;
    } catch (e) {
      debugPrint('[FavoriteProvider] Failed to update note: $e');
      return false;
    }
  }

  /// Gọi khi đăng xuất — hủy listener, tránh lộ dữ liệu tài khoản cũ sang phiên
  /// đăng nhập mới (sẽ được nối khi module Logout được xây).
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _favorites = const [];
    _status = FavoriteListStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
