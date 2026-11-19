import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/section_app_bar.dart';
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
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
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
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,

      appBar: const SectionAppBar(
        title: 'Radio',
        subtitle: 'Estaciones para cada momento',
        icon: Icons.radio_rounded,
      ),

      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          if (appProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isDark
                                  ? const [Color(0xFF34244F), Color(0xFF211A30)]
                                  : [colors.primary, colors.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primary.withValues(
                                  alpha: isDark ? 0.18 : 0.2,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -34,
                                top: -55,
                                child: Container(
                                  width: 145,
                                  height: 145,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.16,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.graphic_eq_rounded,
                                                color: Colors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'RADIO EN VIVO',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        const Text(
                                          'Tu música,\ntu momento.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 23,
                                            height: 1.12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          'Descubre sonidos que van contigo',
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.82,
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.album_rounded,
                                      color: Colors.white,
                                      size: 31,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: TextStyle(
                            color: colors.onSurface,
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
                            fillColor: colors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colors.outline.withValues(alpha: 0.45),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: colors.primary,
                                width: 1.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _categories.map((category) {
                            final isSelected = category == _selectedCategory;

                            return ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              selectedColor: colors.primary,
                              backgroundColor: colors.surface,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              side: BorderSide(
                                color: isSelected
                                    ? colors.primary
                                    : colors.outline.withValues(alpha: 0.5),
                              ),
                              showCheckmark: false,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 25),

                        _sectionHeading('En tendencia'),

                        const SizedBox(height: 12),

                        if (filteredStations.isEmpty)
                          _emptyStations()
                        else
                          _stationCarousel(
                            filteredStations,
                            (station) => _TrendingStationCard(
                              station: station,
                              isActive: audio.currentStation?.id == station.id,
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
                              onTap: () => _selectStation(station),
                            ),
                          ),

                        const SizedBox(height: 25),

                        _sectionHeading('Estaciones populares'),

                        const SizedBox(height: 13),

                        if (filteredStations.isEmpty)
                          const SizedBox.shrink()
                        else
                          SizedBox(
                            height: 112,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(right: 8),
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
                              Row(
                                children: [
                                  Text(
                                    '${favoriteStations.length} estaciones',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.swipe_rounded,
                                    color: colors.primary,
                                    size: 15,
                                  ),
                                ],
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
                          _stationCarousel(
                            favoriteStations,
                            (station) => _TrendingStationCard(
                              station: station,
                              isActive: audio.currentStation?.id == station.id,
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
                              onTap: () => _selectStation(station),
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

                        _sectionHeading('Programas destacados'),

                        const SizedBox(height: 5),

                        Text(
                          selectedStation == null
                              ? 'Historias, música y sesiones para acompañarte'
                              : 'Selección de ${selectedStation.name}',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
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
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
    );
  }

  Widget _sectionHeading(String title) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: _sectionTitle(title)),
        Icon(Icons.swipe_rounded, color: colors.primary, size: 15),
        const SizedBox(width: 5),
        Text(
          'DESLIZA',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }

  Widget _stationCarousel(
    List<StationModel> stations,
    Widget Function(StationModel station) itemBuilder,
  ) {
    return SizedBox(
      height: 184,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: stations.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SizedBox(
                width: constraints.maxWidth,
                child: itemBuilder(stations[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyStations() {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
      ),
      child: Text(
        'No encontramos estaciones. Prueba con otro nombre o categoría.',
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
      ),
    );
  }

  Widget _favoriteMessage(IconData icon, String message) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: const Color(0x1834244F),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              station.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Container(
                  color: colors.surfaceContainerHighest,
                  child: Icon(
                    Icons.radio_rounded,
                    color: colors.primary,
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
                  colors: [Colors.transparent, Color(0xE6000000)],
                ),
              ),
            ),

            Positioned(
              left: 16,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive
                      ? (isPlaying ? '● EN VIVO' : 'EN PAUSA')
                      : 'DESTACADA',
                  style: const TextStyle(
                    color: Color(0xFF30283B),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            ),

            Positioned(
              top: 12,
              right: 12,
              child: Material(
                color: Colors.black.withValues(alpha: 0.48),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: isFavoriteUpdating ? null : onFavoriteTap,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 40,
                    height: 40,
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
                              size: 21,
                            ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 68,
              bottom: 17,
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
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.slogan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  isActive && isPlaying
                      ? Icons.equalizer_rounded
                      : Icons.play_arrow_rounded,
                  color: colors.onPrimary,
                  size: 24,
                ),
              ),
            ),
          ],
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
    final colors = Theme.of(context).colorScheme;

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
                      color: isActive
                          ? colors.primary
                          : colors.outline.withValues(alpha: 0.55),
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
                          color: colors.surfaceContainerHighest,
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
              style: TextStyle(
                color: colors.onSurface,
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
