import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_theme.dart';
import '../helpers/providers/app_provider.dart';
import '../helpers/providers/audio_provider.dart';
import '../helpers/providers/radio_favorites_provider.dart';
import '../models/station_model.dart';
import '../widgets/mini_player.dart';
import '../widgets/program_carousel.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Todas';

  final List<String> _categories = const [
    'Todas',
    'Ambient',
    'Lounge',
    'Indie Pop',
    'Synthwave',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AppProvider>().loadData();
      context.read<RadioFavoritesProvider>().loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectStation(StationModel station) {
    context.read<AudioProvider>().playStation(station);
  }

  void _openFullPlayer(StationModel station) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.96,
          minChildSize: 0.78,
          maxChildSize: 0.99,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              clipBehavior: Clip.antiAlias,
              child: PlayerScreen(
                station: station,
                scrollController: scrollController,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 22,
        title: const Text(
          'Discover',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border),
              ),
              child: const Icon(
                Icons.radio_rounded,
                color: AppTheme.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),

      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return Consumer<AudioProvider>(
            builder: (context, audio, child) {
              return Consumer<RadioFavoritesProvider>(
                builder: (context, favorites, child) {
                  final query = _searchController.text.trim().toLowerCase();

                  final filteredStations = appProvider.stations.where((
                    station,
                  ) {
                    final matchesCategory =
                        _selectedCategory == 'Todas' ||
                        station.category == _selectedCategory;

                    final matchesSearch =
                        query.isEmpty ||
                        station.name.toLowerCase().contains(query) ||
                        station.slogan.toLowerCase().contains(query) ||
                        station.category.toLowerCase().contains(query);

                    return matchesCategory && matchesSearch;
                  }).toList();

                  final favoriteStations = appProvider.stations
                      .where((station) => favorites.isFavorite(station.id))
                      .toList();

                  final selectedStation = audio.currentStation;

                  final programs = selectedStation == null
                      ? appProvider.programs
                      : appProvider.getProgramsByStation(selectedStation.id);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 115),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Encuentra tu siguiente sonido favorito',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 17),

                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Buscar artista, estación o estilo',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchController.text.isEmpty
                                ? const Icon(Icons.tune_rounded, size: 20)
                                : IconButton(
                                    tooltip: 'Limpiar búsqueda',
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                            filled: true,
                            fillColor: AppTheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppTheme.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: AppTheme.primary,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 37,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final category = _categories[index];

                              final isSelected = category == _selectedCategory;

                              return ChoiceChip(
                                label: Text(category),
                                selected: isSelected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                selectedColor: AppTheme.primary,
                                backgroundColor: AppTheme.surface,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.border,
                                ),
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 25),

                        _sectionTitle('En tendencia'),

                        const SizedBox(height: 12),

                        if (filteredStations.isEmpty)
                          _emptyStations()
                        else
                          SizedBox(
                            height: 142,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredStations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final station = filteredStations[index];

                                return _TrendingStationCard(
                                  station: station,
                                  isActive:
                                      audio.currentStation?.id == station.id,
                                  isPlaying:
                                      audio.currentStation?.id == station.id &&
                                      audio.isPlaying,
                                  isFavorite: favorites.isFavorite(station.id),
                                  isFavoriteUpdating: favorites.isUpdating(
                                    station.id,
                                  ),
                                  onFavoriteTap: () {
                                    favorites.toggleFavorite(station.id);
                                  },
                                  onTap: () {
                                    _selectStation(station);
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 25),

                        _sectionTitle('Estaciones populares'),

                        const SizedBox(height: 13),

                        if (filteredStations.isEmpty)
                          const SizedBox.shrink()
                        else
                          SizedBox(
                            height: 112,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: filteredStations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 17),
                              itemBuilder: (context, index) {
                                final station = filteredStations[index];

                                return _PopularStationAvatar(
                                  station: station,
                                  isActive:
                                      audio.currentStation?.id == station.id,
                                  onTap: () {
                                    _selectStation(station);
                                  },
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionTitle('Mis favoritas'),
                            if (favoriteStations.isNotEmpty)
                              Text(
                                '${favoriteStations.length} estaciones',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        if (favorites.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(18),
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            ),
                          )
                        else if (favorites.errorMessage != null &&
                            favoriteStations.isEmpty)
                          _favoriteMessage(
                            Icons.cloud_off_rounded,
                            favorites.errorMessage!,
                          )
                        else if (favoriteStations.isEmpty)
                          _favoriteMessage(
                            Icons.favorite_border_rounded,
                            'Todavía no tienes estaciones favoritas. '
                            'Pulsa el corazón de una estación para guardarla.',
                          )
                        else
                          SizedBox(
                            height: 142,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: favoriteStations.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final station = favoriteStations[index];

                                return _TrendingStationCard(
                                  station: station,
                                  isActive:
                                      audio.currentStation?.id == station.id,
                                  isPlaying:
                                      audio.currentStation?.id == station.id &&
                                      audio.isPlaying,
                                  isFavorite: true,
                                  isFavoriteUpdating: favorites.isUpdating(
                                    station.id,
                                  ),
                                  onFavoriteTap: () {
                                    favorites.toggleFavorite(station.id);
                                  },
                                  onTap: () {
                                    _selectStation(station);
                                  },
                                );
                              },
                            ),
                          ),

                        if (favorites.errorMessage != null &&
                            favoriteStations.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              favorites.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 10,
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),

                        _sectionTitle('Programas destacados'),

                        const SizedBox(height: 5),

                        Text(
                          selectedStation == null
                              ? 'Historias, música y sesiones para acompañarte'
                              : 'Selección de ${selectedStation.name}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 12),

                        ProgramCarousel(programs: programs),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: MiniPlayer(
          onTap: () {
            final station = context.read<AudioProvider>().currentStation;

            if (station != null) {
              _openFullPlayer(station);
            }
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _emptyStations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Text(
        'No encontramos estaciones. Prueba con otro nombre o categoría.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _favoriteMessage(IconData icon, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingStationCard extends StatelessWidget {
  final StationModel station;
  final bool isActive;
  final bool isPlaying;
  final bool isFavorite;
  final bool isFavoriteUpdating;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const _TrendingStationCard({
    required this.station,
    required this.isActive,
    required this.isPlaying,
    required this.isFavorite,
    required this.isFavoriteUpdating,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 258,
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(19),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: const Color(0x1834244F),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                station.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(
                    color: AppTheme.surfaceElevated,
                    child: const Icon(
                      Icons.radio_rounded,
                      color: AppTheme.primary,
                      size: 42,
                    ),
                  );
                },
              ),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD9000000)],
                  ),
                ),
              ),

              Positioned(
                left: 13,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive
                        ? (isPlaying ? '● EN VIVO' : 'EN PAUSA')
                        : 'DESTACADA',
                    style: const TextStyle(
                      color: Color(0xFF30283B),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.48),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: isFavoriteUpdating ? null : onFavoriteTap,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(
                        child: isFavoriteUpdating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? Colors.pinkAccent
                                    : Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 13,
                right: 52,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      station.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      station.slogan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 11,
                bottom: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isActive && isPlaying
                        ? Icons.equalizer_rounded
                        : Icons.play_arrow_rounded,
                    color: AppTheme.primary,
                    size: 21,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularStationAvatar extends StatelessWidget {
  final StationModel station;
  final bool isActive;
  final VoidCallback onTap;

  const _PopularStationAvatar({
    required this.station,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppTheme.primary : AppTheme.border,
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: ClipOval(
                    child: Image.network(
                      station.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: AppTheme.surfaceElevated,
                          child: const Icon(
                            Icons.radio_rounded,
                            color: AppTheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                if (isActive)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF36A56B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 7),

            Text(
              station.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
