import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  final FirebaseFirestore _db;

  BookmarkService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  static const String _legacyBookmarksKey = 'saved_news_ids';

  static const String _migrationField = 'favoriteNewsMigrationV1';

  static const String _favoritesField = 'favoriteNewsIds';

  String _keyForUser(String userId) {
    return 'saved_news_ids_$userId';
  }

  DocumentReference<Map<String, dynamic>> _userDocument(String userId) {
    return _db.collection('users').doc(userId);
  }

  void _validateUserId(String userId) {
    if (userId.trim().isEmpty) {
      throw ArgumentError('El identificador del usuario es obligatorio.');
    }
  }

  Set<int> _parseIds(dynamic value) {
    if (value is! List) {
      return {};
    }

    return value
        .map((item) => int.tryParse(item.toString()))
        .whereType<int>()
        .toSet();
  }

  Future<List<int>> getBookmarkedIds({required String userId}) async {
    _validateUserId(userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final userKey = _keyForUser(userId);

    final localIds = (prefs.getStringList(userKey) ?? [])
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toSet();

    final legacyIds = (prefs.getStringList(_legacyBookmarksKey) ?? [])
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toSet();

    final userRef = _userDocument(userId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      final data = snapshot.data() ?? {};

      if (data[_migrationField] == true) {
        return;
      }

      final idsToMigrate = <int>{...localIds, ...legacyIds};

      transaction.set(userRef, {
        _favoritesField: FieldValue.arrayUnion(idsToMigrate.toList()),
        _migrationField: true,
      }, SetOptions(merge: true));
    });

    final snapshot = await userRef.get();

    final remoteIds = _parseIds(snapshot.data()?[_favoritesField]);

    final savedLocally = await prefs.setStringList(
      userKey,
      remoteIds.map((id) => id.toString()).toList(),
    );

    if (savedLocally && legacyIds.isNotEmpty) {
      await prefs.remove(_legacyBookmarksKey);
    }

    debugPrint('BOOKMARKS: Favoritos sincronizados para $userId: $remoteIds');

    return remoteIds.toList();
  }

  Future<bool> isBookmarked({
    required String userId,
    required int newsId,
  }) async {
    final ids = await getBookmarkedIds(userId: userId);

    return ids.contains(newsId);
  }

  Future<void> addBookmark({
    required String userId,
    required int newsId,
  }) async {
    _validateUserId(userId);

    await _userDocument(userId).set({
      _favoritesField: FieldValue.arrayUnion([newsId]),
      _migrationField: true,
    }, SetOptions(merge: true));

    await _updateLocalCache(userId: userId, newsId: newsId, add: true);

    debugPrint('BOOKMARKS: Noticia $newsId guardada para $userId');
  }

  Future<void> removeBookmark({
    required String userId,
    required int newsId,
  }) async {
    _validateUserId(userId);

    await _userDocument(userId).set({
      _favoritesField: FieldValue.arrayRemove([newsId]),
      _migrationField: true,
    }, SetOptions(merge: true));

    await _updateLocalCache(userId: userId, newsId: newsId, add: false);

    debugPrint('BOOKMARKS: Noticia $newsId eliminada para $userId');
  }

  Future<void> _updateLocalCache({
    required String userId,
    required int newsId,
    required bool add,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.reload();

      final key = _keyForUser(userId);

      final ids = (prefs.getStringList(key) ?? [])
          .map((id) => int.tryParse(id))
          .whereType<int>()
          .toSet();

      if (add) {
        ids.add(newsId);
      } else {
        ids.remove(newsId);
      }

      final success = await prefs.setStringList(
        key,
        ids.map((id) => id.toString()).toList(),
      );

      if (!success) {
        debugPrint('BOOKMARKS: No se pudo actualizar la caché local.');
      }
    } catch (error) {
      debugPrint('BOOKMARKS: Error actualizando caché local: $error');
    }
  }
}
