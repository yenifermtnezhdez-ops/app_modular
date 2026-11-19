import 'package:cloud_firestore/cloud_firestore.dart';

import 'radio_favorites_repository.dart';

class FirebaseRadioFavoritesRepository implements RadioFavoritesRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<List<String>> getFavoriteStationIds(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    final favorites = snapshot.data()?['favoriteStations'];

    if (favorites is! List) return const [];

    return favorites.map((stationId) => stationId.toString()).toList();
  }

  @override
  Future<void> addFavoriteStation({
    required String uid,
    required String stationId,
  }) async {
    await _db.collection('users').doc(uid).set({
      'favoriteStations': FieldValue.arrayUnion([stationId]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> removeFavoriteStation({
    required String uid,
    required String stationId,
  }) async {
    await _db.collection('users').doc(uid).set({
      'favoriteStations': FieldValue.arrayRemove([stationId]),
    }, SetOptions(merge: true));
  }
}
