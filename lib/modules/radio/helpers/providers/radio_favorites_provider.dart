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

  Set<String> get favoriteStationIds => Set.unmodifiable(_favoriteStationIds);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool isFavorite(String stationId) {
    return _favoriteStationIds.contains(stationId);
  }

  bool isUpdating(String stationId) {
    return _updatingStationIds.contains(stationId);
  }

  Future<void> loadFavorites() async {
    final uid = currentUserId();

    if (uid == null) {
      _favoriteStationIds.clear();
      _loadedUserId = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _favoriteStationIds.clear();
    _loadedUserId = uid;
    notifyListeners();

    try {
      final ids = await repository.getFavoriteStationIds(uid);
      if (currentUserId() != uid) return;

      _favoriteStationIds.addAll(ids);
    } catch (error) {
      _errorMessage = 'No se pudieron cargar los favoritos.';
      debugPrint('Error cargando favoritos: $error');
    } finally {
      if (currentUserId() == uid) {
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

    if (_updatingStationIds.contains(stationId)) return;
    if (_loadedUserId != uid) {
      await loadFavorites();
      if (currentUserId() != uid) return;
    }

    final wasFavorite = _favoriteStationIds.contains(stationId);

    _updatingStationIds.add(stationId);
    _errorMessage = null;
    notifyListeners();

    try {
      if (wasFavorite) {
        await repository.removeFavoriteStation(uid: uid, stationId: stationId);

        if (currentUserId() == uid) {
          _favoriteStationIds.remove(stationId);
        }
      } else {
        await repository.addFavoriteStation(uid: uid, stationId: stationId);

        if (currentUserId() == uid) {
          _favoriteStationIds.add(stationId);
        }
      }
    } catch (error) {
      _errorMessage = 'No se pudo actualizar el favorito.';
      debugPrint('Error actualizando favorito: $error');
    } finally {
      _updatingStationIds.remove(stationId);
      notifyListeners();
    }
  }
}
