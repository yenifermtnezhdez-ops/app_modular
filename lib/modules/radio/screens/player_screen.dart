
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_theme.dart';
import '../helpers/providers/app_provider.dart';
import '../helpers/providers/audio_provider.dart';
import '../helpers/radio_utils.dart';
import '../models/station_model.dart';
import '../services/app_service.dart';


class PlayerScreen extends StatelessWidget {
  final StationModel station;
  final ScrollController scrollController;

  const PlayerScreen({
    super.key,
    required this.station,
    required this.scrollController,
  });

  Future<void> _openLink(BuildContext context, String url) async {
    final opened = await AppService.launchExternalUrl(url);

    if (!context.mounted) return;

    if (!opened) {
      AppUtils.showMessage(
        context,
        'No se pudo abrir el enlace. Verifica la URL.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, child) {
        final activeStation = audio.currentStation ?? station;
        final isPlaying = audio.isPlaying;
        final isLoading = audio.isLoading;
        final hasError = audio.hasError;

        final stations = context.watch<AppProvider>().stations;

        final currentStationIndex = stations.indexWhere(
          (item) => item.id == activeStation.id,
        );

        final canChangeStation =
            stations.length > 1 && currentStationIndex >= 0;

        void changeStation(int direction) {
          if (!canChangeStation || isLoading) return;

          final nextIndex =
              (currentStationIndex + direction + stations.length) %
                  stations.length;

          audio.playStation(stations[nextIndex]);
        }

        final status = hasError
            ? 'ERROR DE REPRODUCCIÓN'
            : isLoading
                ? 'CONECTANDO...'
                : isPlaying
                    ? 'EN VIVO'
                    : audio.currentStation != null
                        ? 'EN PAUSA'
                        : 'LISTA PARA REPRODUCIR';

        final statusColor = hasError
            ? const Color(0xFFB83D4B)
            : isPlaying
                ? const Color(0xFF278253)
                : AppTheme.primary;

        final socialLinks = <Map<String, dynamic>>[
          if (activeStation.xUrl.trim().isNotEmpty)
            {
              'name': 'X',
              'icon': Icons.alternate_email_rounded,
              'url': activeStation.xUrl,
            },
          if (activeStation.instagramUrl.trim().isNotEmpty)
            {
              'name': 'Instagram',
              'icon': Icons.camera_alt_outlined,
              'url': activeStation.instagramUrl,
            },
        ];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 12, 2),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'REPRODUCTOR',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Cerrar reproductor',
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.surfaceElevated,
                      foregroundColor: AppTheme.textPrimary,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),

                        // Portada de la estación
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(30),
                            border: const Border.fromBorderSide(
                              BorderSide(color: AppTheme.border),
                            ),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(23),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Image.network(
                                activeStation.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppTheme.surfaceElevated,
                                  child: const Icon(
                                    Icons.album_rounded,
                                    color: AppTheme.primary,
                                    size: 100,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.20),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isLoading)
                                SizedBox(
                                  width: 13,
                                  height: 13,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: statusColor,
                                  ),
                                )
                              else
                                Icon(
                                  isPlaying
                                      ? Icons.graphic_eq_rounded
                                      : Icons.radio_rounded,
                                  size: 15,
                                  color: statusColor,
                                ),
                              const SizedBox(width: 7),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                  
                        Text(
                          activeStation.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 25,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 7),

                      
                        Text(
                          activeStation.slogan,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '${activeStation.frequency}  •  ${activeStation.category}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 10,
                            letterSpacing: 0.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 24),

                    
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: const Border.fromBorderSide(
                              BorderSide(color: AppTheme.border),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: List.generate(27, (index) {
                              final heights = [
                                12, 20, 30, 17, 37, 24, 44, 18, 31,
                                48, 23, 37, 15, 43, 28, 50, 19, 35,
                                24, 42, 16, 32, 45, 20, 36, 15, 27,
                              ];

                              return Container(
                                width: 4,
                                height: heights[index].toDouble(),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: isPlaying ? 0.85 : 0.28,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              );
                            }),
                          ),
                        ),

                        const SizedBox(height: 22),

                       
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _roundControl(
                              icon: Icons.skip_previous_rounded,
                              tooltip: 'Estación anterior',
                              onPressed: canChangeStation && !isLoading
                                  ? () => changeStation(-1)
                                  : null,
                            ),

                            const SizedBox(width: 25),

                            SizedBox(
                              width: 72,
                              height: 72,
                              child: FilledButton(
                                onPressed: isLoading || hasError
                                    ? null
                                    : () {
                                        if (isPlaying) {
                                          audio.pause();
                                        } else if (
                                            audio.currentStation != null) {
                                          audio.resume();
                                        } else {
                                          audio.playStation(activeStation);
                                        }
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      AppTheme.primary.withValues(alpha: 0.35),
                                  shape: const CircleBorder(),
                                  elevation: 7,
                                  shadowColor:
                                      AppTheme.primary.withValues(alpha: 0.25),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 39,
                                ),
                              ),
                            ),

                            const SizedBox(width: 25),

                            _roundControl(
                              icon: Icons.skip_next_rounded,
                              tooltip: 'Siguiente estación',
                              onPressed: canChangeStation && !isLoading
                                  ? () => changeStation(1)
                                  : null,
                            ),
                          ],
                        ),

                  
                        if (hasError) ...[
                          const SizedBox(height: 16),
                          Text(
                            audio.errorMessage ?? 'Error de reproducción',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFB83D4B),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              audio.playStation(activeStation);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Intentar nuevamente'),
                          ),
                        ],

                        const SizedBox(height: 25),

                    
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(22),
                            border: const Border.fromBorderSide(
                              BorderSide(color: AppTheme.border),
                            ),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sobre esta estación',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activeStation.description,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 13),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _infoChip(activeStation.acronym),
                                  _infoChip(activeStation.category),
                                  _infoChip('Radio en línea'),
                                ],
                              ),
                            ],
                          ),
                        ),

                  
                        if (activeStation.websiteUrl.trim().isNotEmpty) ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _openLink(
                                context,
                                activeStation.websiteUrl,
                              ),
                              icon: const Icon(Icons.language_rounded),
                              label: const Text('Visitar página web'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                                side: const BorderSide(
                                  color: AppTheme.border,
                                ),
                                backgroundColor: AppTheme.surface,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],

                   
                        if (socialLinks.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'Encuéntranos en redes',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            children: socialLinks.map((social) {
                              return TextButton.icon(
                                onPressed: () => _openLink(
                                  context,
                                  social['url'] as String,
                                ),
                                icon: Icon(social['icon'] as IconData),
                                label: Text(social['name'] as String),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  backgroundColor: AppTheme.surfaceElevated,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _roundControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: AppTheme.textPrimary,
      iconSize: 24,
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.surface,
        side: const BorderSide(color: AppTheme.border),
        fixedSize: const Size(48, 48),
      ),
    );
  }


  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
