import '../models/favorite_meal_model.dart';
import 'favorite_local_data_source.dart';
import 'favorite_remote_data_source.dart';
import 'favorite_repository.dart';

/// Điều phối FavoriteRemoteDataSource (nguồn thật) + FavoriteLocalDataSource
/// (cache đọc nhanh) — là implementation duy nhất của FavoriteRepository.
class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl({
    required FavoriteRemoteDataSource remoteDataSource,
    required FavoriteLocalDataSource localDataSource,
  })  : _remote = remoteDataSource,
        _local = localDataSource;

  final FavoriteRemoteDataSource _remote;
  final FavoriteLocalDataSource _local;

  @override
  Stream<List<FavoriteMealModel>> watchFavorites(String uid) {
    return _remote.watchFavorites(uid).map((favorites) {
      _local.syncFromRemote(favorites);
      return favorites;
    });
  }

  @override
  Future<FavoriteMealModel?> getFavoriteStatus(String uid, String idMeal) async {
    final cached = _local.getCached(idMeal);
    if (cached != null) return cached;
    return _remote.getFavorite(uid, idMeal);
  }

  @override
  Future<void> addFavorite({
    required String uid,
    required String idMeal,
    required String mealName,
    required String mealThumbnail,
  }) {
    final now = DateTime.now();
    return _remote.setFavorite(
      uid,
      FavoriteMealModel(
        idMeal: idMeal,
        mealName: mealName,
        mealThumbnail: mealThumbnail,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> removeFavorite(String uid, String idMeal) {
    return _remote.deleteFavorite(uid, idMeal);
  }

  @override
  Future<bool> toggleFavorite({
    required String uid,
    required String idMeal,
    required String mealName,
    required String mealThumbnail,
  }) {
    final now = DateTime.now();
    final candidate = FavoriteMealModel(
      idMeal: idMeal,
      mealName: mealName,
      mealThumbnail: mealThumbnail,
      createdAt: now,
      updatedAt: now,
    );
    return _remote.toggleFavorite(uid, candidate);
  }

  @override
  Future<void> updateNote(String uid, String idMeal, String note) {
    return _remote.updateNote(uid, idMeal, note, DateTime.now());
  }
}
