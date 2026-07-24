import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/favorite_meal_model.dart';

/// Nguồn dữ liệu thật — nơi DUY NHẤT chạm vào Cloud Firestore SDK cho dữ liệu
/// Favorite, theo path `users/{uid}/favorites/{idMeal}` (DATABASE_DESIGN.md mục 2.2).
class FavoriteRemoteDataSource {
  FavoriteRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _favoritesCollection(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<List<FavoriteMealModel>> watchFavorites(String uid) {
    return _favoritesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => FavoriteMealModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<FavoriteMealModel?> getFavorite(String uid, String idMeal) async {
    final doc = await _favoritesCollection(uid).doc(idMeal).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return FavoriteMealModel.fromMap(doc.id, data);
  }

  Future<void> setFavorite(String uid, FavoriteMealModel favorite) {
    return _favoritesCollection(uid).doc(favorite.idMeal).set(favorite.toMap());
  }

  Future<void> deleteFavorite(String uid, String idMeal) {
    return _favoritesCollection(uid).doc(idMeal).delete();
  }

  Future<void> updateNote(String uid, String idMeal, String note, DateTime updatedAt) {
    return _favoritesCollection(uid).doc(idMeal).update({
      'note': note,
      'updatedAt': Timestamp.fromDate(updatedAt),
    });
  }

  /// Toggle an toàn bằng Firestore Transaction — đọc rồi ghi/xóa trong cùng 1
  /// giao dịch, tránh race condition khi người dùng bấm nhanh liên tục
  /// (DATABASE_DESIGN.md mục 11). Trả về true nếu kết quả cuối là "đã lưu".
  Future<bool> toggleFavorite(String uid, FavoriteMealModel candidate) {
    final docRef = _favoritesCollection(uid).doc(candidate.idMeal);
    return _firestore.runTransaction<bool>((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (snapshot.exists) {
        transaction.delete(docRef);
        return false;
      }
      transaction.set(docRef, candidate.toMap());
      return true;
    });
  }
}
