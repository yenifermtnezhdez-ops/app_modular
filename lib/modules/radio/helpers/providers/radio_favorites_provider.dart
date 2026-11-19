import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../services/radio_favorites_repository.dart';

class RadioFavoritesProvider extends ChangeNotifier {
  final RadioFavoritesRepository repository;
  final String? Function() currentUserId;

  RadioFavoritesProvider({
    required this.repository,
    required this.currentUserId,
  });

  final Set<String> _favoriteStationIds = {};
  final Set<String> _updatingStationIds = {};

  bool _isLoading = false;
  String? _errorMessage;
  String? _loadedUserId;
  String? _activeUserId;

  int _loadRevision = 0;

  Set<String> get favoriteStationIds => Set.unmodifiable(_favoriteStationIds);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool isFavorite(String stationId) {
    return _favoriteStationIds.contains(stationId);
  }

  bool isUpdating(String stationId) {
    return _updatingStationIds.contains(stationId);
  }

  void setUserId(String? userId) {
    if (_activeUserId == userId) return;

    _activeUserId = userId;
    _loadedUserId = null;

    _loadRevision++;

    _favoriteStationIds.clear();
    _updatingStationIds.clear();
    _errorMessage = null;

    _isLoading = userId != null;

    notifyListeners();

    if (userId != null) {
      unawaited(loadFavorites());
    }
  }

  Future<void> loadFavorites() async {
    final uid = _activeUserId;
    if (uid == null || currentUserId() != uid) return;

    final revision = ++_loadRevision;

    _isLoading = true;
    _errorMessage = null;
    _favoriteStationIds.clear();

    notifyListeners();

    try {
      final ids = await repository.getFavoriteStationIds(uid);

      if (_activeUserId != uid ||
          currentUserId() != uid ||
          revision != _loadRevision) {
        return;
      }

      _favoriteStationIds.addAll(ids);
      _loadedUserId = uid;
    } catch (error) {
      if (_activeUserId != uid || revision != _loadRevision) {
        return;
      }

      _errorMessage = 'No se pudieron cargar los favoritos.';
      debugPrint('Error cargando favoritos: $error');
    } finally {
      if (_activeUserId == uid && revision == _loadRevision) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleFavorite(String stationId) async {
    final uid = currentUserId();

    if (uid == null) {
      _errorMessage = 'Debes iniciar sesión para guardar favoritos.';
      notifyListeners();
      return;
    }

    if (_activeUserId != uid) {
      setUserId(uid);
    }

    if (_updatingStationIds.contains(stationId)) return;

    if (_loadedUserId != uid) {
      await loadFavorites();

      if (_activeUserId != uid ||
          currentUserId() != uid ||
          _loadedUserId != uid) {
        return;
      }
    }

    final wasFavorite = _favoriteStationIds.contains(stationId);

    _updatingStationIds.add(stationId);
    _errorMessage = null;

    notifyListeners();

    try {
      if (wasFavorite) {
        await repository.removeFavoriteStation(uid: uid, stationId: stationId);

        if (_activeUserId == uid && currentUserId() == uid) {
          _favoriteStationIds.remove(stationId);
        }
      } else {
        await repository.addFavoriteStation(uid: uid, stationId: stationId);

        if (_activeUserId == uid && currentUserId() == uid) {
          _favoriteStationIds.add(stationId);
        }
      }
    } catch (error) {
      if (_activeUserId == uid && currentUserId() == uid) {
        _errorMessage = 'No se pudo actualizar el favorito.';
      }

      debugPrint('Error actualizando favorito: $error');
    } finally {
      _updatingStationIds.remove(stationId);
      notifyListeners();
    }
  }
}
