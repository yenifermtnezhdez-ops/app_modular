
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_theme.dart';
import '../helpers/providers/app_provider.dart';
import '../helpers/providers/audio_provider.dart';
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
      if (mounted) {
        context.read<AppProvider>().loadData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Seleccionar una estación sin modificar la lógica de audio.
  void _selectStation(StationModel station) {
    context.read<AudioProvider>().playStation(station);
  }

  // Abrir el reproductor completo.
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
                borderRadius: BorderRadius.vertical(
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
    return Scaffold(
      backgroundColor: AppTheme.background,

      // Permite que el fondo continúe por detrás
      // del espacio ocupado por el mini reproductor.
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
                border: Border.all(
                  color: AppTheme.border,
                ),
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
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            );
          }

          return Consumer<AudioProvider>(
            builder: (context, audio, child) {
              final query =
                  _searchController.text.trim().toLowerCase();

              final filteredStations = appProvider.stations.where((station) {
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

              final selectedStation = audio.currentStation;

              final programs = selectedStation == null
                  ? appProvider.programs
                  : appProvider.getProgramsByStation(
                      selectedStation.id,
                    );

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                // Espacio inferior para que el contenido
                // no quede escondido detrás del mini reproductor.
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  115,
                ),

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

                    // BUSCADOR
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar artista, estación o estilo',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                        ),
                        suffixIcon: _searchController.text.isEmpty
                            ? const Icon(
                                Icons.tune_rounded,
                                size: 20,
                              )
                            : IconButton(
                                tooltip: 'Limpiar búsqueda',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              ),
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
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

                    // FILTROS DE CATEGORÍAS
                    SizedBox(
                      height: 37,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected =
                              category == _selectedCategory;

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

                    // ESTACIONES EN TENDENCIA
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
                              onTap: () => _selectStation(station),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 25),

                    // ESTACIONES POPULARES
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
                              onTap: () => _selectStation(station),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 25),

                    // PROGRAMAS DESTACADOS
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

                    ProgramCarousel(
                      programs: programs,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      // MINI REPRODUCTOR FLOTANTE
      bottomNavigationBar: Material(
        color: Colors.transparent,
        child: MiniPlayer(
          onTap: () {
            final station =
                context.read<AudioProvider>().currentStation;

            if (station != null) {
              _openFullPlayer(station);
            }
          },
        ),
      ),
    );
  }

  // Títulos de las secciones.
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

  // Mensaje cuando no hay estaciones disponibles.
  Widget _emptyStations() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: const Text(
        'No encontramos estaciones. Prueba con otro nombre o categoría.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

// TARJETA DE ESTACIÓN DESTACADA

class _TrendingStationCard extends StatelessWidget {
  final StationModel station;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const _TrendingStationCard({
    required this.station,
    required this.isActive,
    required this.isPlaying,
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
                    colors: [
                      Colors.transparent,
                      Color(0xD9000000),
                    ],
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

// AVATAR DE ESTACIÓN POPULAR

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
                      color: isActive
                          ? AppTheme.primary
                          : AppTheme.border,
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
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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
