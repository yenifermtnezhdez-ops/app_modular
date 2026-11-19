import '../../radio/services/radio_favorites_repository.dart';
import 'user_service.dart';

class FirebaseRadioFavoritesRepository implements RadioFavoritesRepository {
  final UserService _userService = UserService();

  @override
  Future<List<String>> getFavoriteStationIds(String uid) {
    return _userService.getFavoriteStationIds(uid);
  }

  @override
  Future<void> addFavoriteStation({
    required String uid,
    required String stationId,
  }) {
    return _userService.addFavoriteStation(uid: uid, stationId: stationId);
  }

  @override
  Future<void> removeFavoriteStation({
    required String uid,
    required String stationId,
  }) {
    return _userService.removeFavoriteStation(uid: uid, stationId: stationId);
  }
}
