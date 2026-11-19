
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../app_theme.dart';
import '../models/program_model.dart';
import 'program_card.dart';

class ProgramCarousel extends StatelessWidget {
  final List<ProgramModel> programs;
  final Function(ProgramModel)? onProgramTap;

  const ProgramCarousel({
    super.key,
    required this.programs,
    this.onProgramTap,
  });

  void _showProgramDetails(
    BuildContext context,
    ProgramModel program,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  program.imageUrl,
                  height: 210,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 210,
                      color: AppTheme.background,
                      child: const Center(
                        child: Icon(
                          Icons.music_note,
                          color: AppTheme.primary,
                          size: 70,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                program.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                program.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              _detailRow(
                Icons.schedule,
                'Horario',
                program.schedule,
              ),

              const SizedBox(height: 14),

              _detailRow(
                Icons.person,
                'Estación / Conductor',
                program.host,
              ),

              const SizedBox(height: 14),

              _detailRow(
                Icons.radio,
                'Identificador',
                program.stationId,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cerrar detalles'),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primary,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (programs.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No hay programas disponibles',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: programs.length,
      itemBuilder: (context, index, realIndex) {
        final program = programs[index];

        return ProgramCard(
          program: program,
          onTap: () {
            onProgramTap?.call(program);
            _showProgramDetails(context, program);
          },
        );
      },
      options: CarouselOptions(
        height: 235,
        viewportFraction: 0.72,
        enlargeCenterPage: false,
        enableInfiniteScroll: programs.length > 1,
        autoPlay: false,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}
