
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  static const String _legacyBookmarksKey = 'saved_news_ids';

  String _keyForUser(String userId) => 'saved_news_ids_$userId';


  Future<List<int>> getBookmarkedIds({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'El identificador del usuario es obligatorio.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final userKey = _keyForUser(userId);
    final savedForUser = prefs.getStringList(userKey) ?? [];
    final legacyBookmarks = prefs.getStringList(_legacyBookmarksKey);

    if (legacyBookmarks != null) {

      final mergedBookmarks = <String>{
        ...savedForUser,
        ...legacyBookmarks,
      }.toList();

      final migrationSuccess = await prefs.setStringList(
        userKey,
        mergedBookmarks,
      );

      if (!migrationSuccess) {
        throw Exception(
          'No fue posible migrar los favoritos anteriores.',
        );
      }

      final removalSuccess = await prefs.remove(_legacyBookmarksKey);

      if (!removalSuccess) {
        debugPrint(
          'BOOKMARKS: No se pudo eliminar la clave antigua.',
        );
      } else {
        debugPrint(
          'BOOKMARKS: Favoritos antiguos migrados al usuario $userId',
        );
      }
    }

    final savedIds = prefs.getStringList(userKey) ?? [];

    final ids = savedIds
        .map((id) => int.tryParse(id))
        .whereType<int>()
        .toSet()
        .toList();

    debugPrint(
      'BOOKMARKS: Favoritos del usuario $userId: $ids',
    );

    return ids;
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
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'El identificador del usuario es obligatorio.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final key = _keyForUser(userId);
    final savedIds = prefs.getStringList(key) ?? [];
    final id = newsId.toString();

    if (!savedIds.contains(id)) {
      savedIds.add(id);

      final success = await prefs.setStringList(
        key,
        savedIds,
      );

      if (!success) {
        throw Exception(
          'No fue posible guardar el favorito.',
        );
      }
    }

    debugPrint(
      'BOOKMARKS: Favorito $newsId guardado para $userId',
    );
  }
  Future<void> removeBookmark({
    required String userId,
    required int newsId,
  }) async {
    if (userId.trim().isEmpty) {
      throw ArgumentError(
        'El identificador del usuario es obligatorio.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final key = _keyForUser(userId);
    final savedIds = prefs.getStringList(key) ?? [];

    savedIds.remove(newsId.toString());

    final success = await prefs.setStringList(
      key,
      savedIds,
    );

    if (!success) {
      throw Exception(
        'No fue posible eliminar el favorito.',
      );
    }

    debugPrint(
      'BOOKMARKS: Favorito $newsId eliminado para $userId',
    );
  }
}
