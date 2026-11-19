abstract class RadioFavoritesRepository {
  Future<List<String>> getFavoriteStationIds(String uid);

  Future<void> addFavoriteStation({
    required String uid,
    required String stationId,
  });

  Future<void> removeFavoriteStation({
    required String uid,
    required String stationId,
  });
}
