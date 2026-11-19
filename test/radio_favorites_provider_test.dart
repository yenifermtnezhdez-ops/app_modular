import 'dart:async';

import 'package:app_modular/modules/radio/helpers/providers/radio_favorites_provider.dart';
import 'package:app_modular/modules/radio/services/radio_favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('coalesces duplicate reads and reuses loaded favorites', () async {
    final repository = _FakeRadioFavoritesRepository();
    const userId = 'user-1';
    final provider = RadioFavoritesProvider(
      repository: repository,
      currentUserId: () => userId,
    );

    provider.setUserId(userId);
    final secondLoad = provider.loadFavorites();

    expect(repository.readCount, 1);

    repository.pendingRead.complete(['station-1']);
    await secondLoad;
    await provider.loadFavorites();

    expect(repository.readCount, 1);
    expect(provider.isFavorite('station-1'), isTrue);
    expect(provider.isLoading, isFalse);

    provider.dispose();
  });
}

class _FakeRadioFavoritesRepository implements RadioFavoritesRepository {
  final Completer<List<String>> pendingRead = Completer<List<String>>();
  int readCount = 0;

  @override
  Future<List<String>> getFavoriteStationIds(String uid) {
    readCount++;
    return pendingRead.future;
  }

  @override
  Future<void> addFavoriteStation({
    required String uid,
    required String stationId,
  }) async {}

  @override
  Future<void> removeFavoriteStation({
    required String uid,
    required String stationId,
  }) async {}
}
