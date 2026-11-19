import 'package:flutter/material.dart';

import '../models/program_model.dart';
import 'program_card.dart';

class ProgramCarousel extends StatelessWidget {
  final List<ProgramModel> programs;
  final Function(ProgramModel)? onProgramTap;

  const ProgramCarousel({super.key, required this.programs, this.onProgramTap});

  void _showProgramDetails(BuildContext context, ProgramModel program) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      elevation: 12,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                    color: colors.outline,
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
                      color: colors.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          color: colors.primary,
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
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                program.description,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              _detailRow(context, Icons.schedule, 'Horario', program.schedule),

              const SizedBox(height: 14),

              _detailRow(
                context,
                Icons.person,
                'Estación / Conductor',
                program.host,
              ),

              const SizedBox(height: 14),

              _detailRow(
                context,
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
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
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
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: colors.onSurface,
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
    final colors = Theme.of(context).colorScheme;

    if (programs.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'No hay programas disponibles',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 235,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: programs.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final program = programs[index];

              return SizedBox(
                width: constraints.maxWidth,
                child: ProgramCard(
                  program: program,
                  onTap: () {
                    onProgramTap?.call(program);
                    _showProgramDetails(context, program);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
