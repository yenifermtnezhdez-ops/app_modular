
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_theme.dart';
import '../helpers/providers/audio_provider.dart';
import '../models/station_model.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback? onTap;

  const MiniPlayer({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, child) {
        final StationModel? station = audio.currentStation;

        if (station == null) {
          return const SizedBox.shrink();
        }

        final status = audio.hasError
            ? 'ERROR DE REPRODUCCIÓN'
            : audio.isLoading
                ? 'CONECTANDO...'
                : audio.isPlaying
                    ? 'EN VIVO'
                    : 'EN PAUSA';

        final statusColor = audio.hasError
            ? const Color(0xFFB83D4B)
            : audio.isPlaying
                ? const Color(0xFF278253)
                : AppTheme.textSecondary;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Material(
              color: AppTheme.surface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFEAE7EF),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.13),
                      blurRadius: 22,
                      spreadRadius: 1,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 76,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 9,
                        ),
                        child: Row(
                          children: [
                            // Portada
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                station.imageUrl,
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) {
                                  return Container(
                                    width: 55,
                                    height: 55,
                                    color: AppTheme.surfaceElevated,
                                    child: const Icon(
                                      Icons.radio_rounded,
                                      color: AppTheme.primary,
                                      size: 26,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Información de la estación
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        audio.isPlaying
                                            ? Icons.graphic_eq_rounded
                                            : Icons.circle,
                                        color: statusColor,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          status,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 9,
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Botón de reproducir / pausar
                            Material(
                              color: AppTheme.primary,
                              shape: const CircleBorder(),
                              child: IconButton(
                                tooltip: audio.isPlaying
                                    ? 'Pausar'
                                    : 'Reanudar',
                                onPressed: audio.isLoading || audio.hasError
                                    ? null
                                    : () {
                                        if (audio.isPlaying) {
                                          audio.pause();
                                        } else {
                                          audio.resume();
                                        }
                                      },
                                icon: Icon(
                                  audio.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                constraints: const BoxConstraints.tightFor(
                                  width: 44,
                                  height: 44,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),

                            const SizedBox(width: 4),

                            // Indicador para abrir el reproductor
                            const Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: AppTheme.textSecondary,
                              size: 23,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
