
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/bookmark_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final BookmarkService _bookmarkService;

  String? _userId;

  Set<int> _bookmarkedIds = {};

  bool _isLoading = false;
  bool _isLoaded = false;

  String? _errorMessage;

  int _loadRevision = 0;

  BookmarkProvider({BookmarkService? bookmarkService})
      : _bookmarkService = bookmarkService ?? BookmarkService();

  Set<int> get bookmarkedIds => Set.unmodifiable(_bookmarkedIds);

  bool get isLoading => _isLoading;

  bool get isLoaded => _isLoaded;

  String? get errorMessage => _errorMessage;

  String? get userId => _userId;

  bool isBookmarked(int newsId) {
    return _bookmarkedIds.contains(newsId);
  }


  void setUserId(String? userId) {
    if (_userId == userId) return;

    _userId = userId;
    final revision = ++_loadRevision;


    _bookmarkedIds = {};
    _errorMessage = null;
    _isLoading = userId != null;
    _isLoaded = userId == null;

    notifyListeners();

    if (userId != null) {
      unawaited(_loadForUser(userId, revision));
    }
  }

  Future<void> loadBookmarks() async {
    final currentUserId = _userId;

    if (currentUserId == null) {
      _bookmarkedIds = {};
      _isLoading = false;
      _isLoaded = true;
      notifyListeners();
      return;
    }

    final revision = ++_loadRevision;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _loadForUser(currentUserId, revision);
  }

  Future<void> _loadForUser(String userId, int revision) async {
    try {
      final ids = await _bookmarkService.getBookmarkedIds(
        userId: userId,
      );


      if (_userId != userId || revision != _loadRevision) return;

      _bookmarkedIds = ids.toSet();
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error al cargar favoritos: $e');

      if (_userId != userId || revision != _loadRevision) return;

      _errorMessage = 'No fue posible cargar los favoritos.';
    } finally {
      if (_userId == userId && revision == _loadRevision) {
        _isLoading = false;
        _isLoaded = true;
        notifyListeners();
      }
    }
  }

  Future<void> toggleBookmark(int newsId) async {
    final currentUserId = _userId;

    if (currentUserId == null) {
      throw Exception('Debes iniciar sesión para guardar favoritos.');
    }

    if (_isLoading) {
      throw Exception('Espera a que terminen de cargar los favoritos.');
    }

    final wasBookmarked = _bookmarkedIds.contains(newsId);


    if (wasBookmarked) {
      _bookmarkedIds.remove(newsId);
    } else {
      _bookmarkedIds.add(newsId);
    }

    notifyListeners();

    try {
      if (wasBookmarked) {
        await _bookmarkService.removeBookmark(
          userId: currentUserId,
          newsId: newsId,
        );
      } else {
        await _bookmarkService.addBookmark(
          userId: currentUserId,
          newsId: newsId,
        );
      }
    } catch (e) {
      debugPrint('Error al actualizar favorito: $e');

      if (_userId == currentUserId) {
        if (wasBookmarked) {
          _bookmarkedIds.add(newsId);
        } else {
          _bookmarkedIds.remove(newsId);
        }

        notifyListeners();
      }

      rethrow;
    }
  }
}
