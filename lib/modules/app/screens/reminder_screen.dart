
import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../models/note_model.dart';
import '../models/reminder_model.dart';
import '../services/event_service.dart';
import '../services/note_service.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final ReminderService _reminderService = ReminderService();
  final NoteService _noteService = NoteService();
  final EventService _eventService = EventService();

  late final Stream<List<ReminderModel>> _remindersStream;
  late final Future<List<NoteModel>> _notesFuture;
  late final Future<List<EventModel>> _eventsFuture;

  @override
  void initState() {
    super.initState();

    _remindersStream = _reminderService.watchReminders();
    _notesFuture = _noteService.getNotes();
    _eventsFuture = _eventService.getEvents();
  }
  int _notificationId(String reminderId) {
    var hash = 0x811c9dc5;

    for (final unit in reminderId.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0x7fffffff;
    }

    return hash == 0 ? 1 : hash;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _noteTitle(String? id, List<NoteModel> notes) {
    if (id == null) return 'Sin nota relacionada';

    for (final note in notes) {
      if (note.id == id) return note.title;
    }

    return 'Nota no disponible';
  }

  String _eventTitle(String? id, List<EventModel> events) {
    if (id == null) return 'Sin evento relacionado';

    for (final event in events) {
      if (event.id == id) return event.title;
    }

    return 'Evento no disponible';
  }

  String _notificationBody({
    required String? noteId,
    required String? eventId,
    required List<NoteModel> notes,
    required List<EventModel> events,
  }) {
    final parts = <String>[];

    if (eventId != null) {
      parts.add(_eventTitle(eventId, events));
    }

    if (noteId != null) {
      parts.add(_noteTitle(noteId, notes));
    }

    if (parts.isEmpty) {
      return 'Es hora de revisar tu recordatorio.';
    }

    return 'Recordatorio relacionado con: ${parts.join(' y ')}';
  }

  Future<DateTime?> _selectDateTime(
    BuildContext context,
    DateTime initialDate,
  ) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !context.mounted) return null;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (selectedTime == null) return null;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _showReminderDialog({
    required List<NoteModel> notes,
    required List<EventModel> events,
    ReminderModel? reminder,
  }) async {
    DateTime scheduledAt = reminder?.scheduledAt ??
        DateTime.now().add(const Duration(hours: 1));

    String? selectedNoteId = reminder?.noteId;
    String? selectedEventId = reminder?.eventId;
    String? errorMessage;
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                reminder == null
                    ? 'Nuevo recordatorio'
                    : 'Editar recordatorio',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Fecha y hora programada',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.alarm),
                      title: Text(_formatDate(scheduledAt)),
                      subtitle: const Text('Toca para cambiar'),
                      onTap: () async {
                        final selected = await _selectDateTime(
                          dialogContext,
                          scheduledAt,
                        );

                        if (selected != null &&
                            dialogContext.mounted) {
                          setDialogState(() {
                            scheduledAt = selected;
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedEventId != null &&
                              events.any(
                                (event) => event.id == selectedEventId,
                              )
                          ? selectedEventId
                          : '',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Evento relacionado (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Ninguno'),
                        ),
                        ...events.map(
                          (event) => DropdownMenuItem<String>(
                            value: event.id,
                            child: Text(
                              event.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedEventId =
                              value == null || value.isEmpty
                                  ? null
                                  : value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedNoteId != null &&
                              notes.any(
                                (note) => note.id == selectedNoteId,
                              )
                          ? selectedNoteId
                          : '',
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Nota relacionada (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: '',
                          child: Text('Ninguna'),
                        ),
                        ...notes.map(
                          (note) => DropdownMenuItem<String>(
                            value: note.id,
                            child: Text(
                              note.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedNoteId =
                              value == null || value.isEmpty
                                  ? null
                                  : value;
                        });
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!scheduledAt.isAfter(DateTime.now())) {
                            setDialogState(() {
                              errorMessage =
                                  'Selecciona una fecha y hora futuras.';
                            });
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            errorMessage = null;
                          });

                          try {
                            final notificationService =
                                NotificationService.instance;

                            if (reminder == null) {
                              // Guardar primero el recordatorio.
                              final reminderId =
                                  await _reminderService.createReminder(
                                scheduledAt: scheduledAt,
                                eventId: selectedEventId,
                                noteId: selectedNoteId,
                              );
                              await notificationService.scheduleNotification(
                                _notificationId(reminderId),
                                'Recordatorio',
                                _notificationBody(
                                  noteId: selectedNoteId,
                                  eventId: selectedEventId,
                                  notes: notes,
                                  events: events,
                                ),
                                scheduledAt,
                              );
                            } else {
                        
                              await notificationService.cancelNotification(
                                _notificationId(reminder.id),
                              );

                              await _reminderService.updateReminder(
                                reminderId: reminder.id,
                                scheduledAt: scheduledAt,
                                eventId: selectedEventId,
                                noteId: selectedNoteId,
                              );

                              await notificationService.scheduleNotification(
                                _notificationId(reminder.id),
                                'Recordatorio',
                                _notificationBody(
                                  noteId: selectedNoteId,
                                  eventId: selectedEventId,
                                  notes: notes,
                                  events: events,
                                ),
                                scheduledAt,
                              );
                            }

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  reminder == null
                                      ? 'Recordatorio creado y notificación programada'
                                      : 'Recordatorio actualizado y notificación reprogramada',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              errorMessage =
                                  'No se pudo completar la operación: $error';
                              isSaving = false;
                            });
                          }
                        },
                  child: Text(isSaving ? 'Guardando...' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar recordatorio'),
        content: const Text(
          '¿Deseas eliminar este recordatorio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _reminderService.deleteReminder(reminder.id);
      await NotificationService.instance.cancelNotification(
        _notificationId(reminder.id),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Recordatorio eliminado y notificación cancelada',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar la operación: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis recordatorios'),
      ),
      body: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, notesSnapshot) {
          if (notesSnapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar notas: ${notesSnapshot.error}',
              ),
            );
          }

          if (!notesSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notes = notesSnapshot.data!;

          return FutureBuilder<List<EventModel>>(
            future: _eventsFuture,
            builder: (context, eventsSnapshot) {
              if (eventsSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error al cargar eventos: ${eventsSnapshot.error}',
                  ),
                );
              }

              if (!eventsSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final events = eventsSnapshot.data!;

              return StreamBuilder<List<ReminderModel>>(
                stream: _remindersStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error al cargar recordatorios:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final reminders = snapshot.data ?? [];

                  if (reminders.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.alarm, size: 64),
                            SizedBox(height: 12),
                            Text(
                              'Todavía no tienes recordatorios.',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 8),
                            Text('Pulsa + para crear uno.'),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.notifications_active),
                          ),
                          title: Text(
                            _formatDate(reminder.scheduledAt),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${_eventTitle(reminder.eventId, events)}\n'
                            '${_noteTitle(reminder.noteId, notes)}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showReminderDialog(
                                  notes: notes,
                                  events: events,
                                  reminder: reminder,
                                );
                              } else if (value == 'delete') {
                                _deleteReminder(reminder);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<NoteModel>>(
        future: _notesFuture,
        builder: (context, notesSnapshot) {
          return FutureBuilder<List<EventModel>>(
            future: _eventsFuture,
            builder: (context, eventsSnapshot) {
              return FloatingActionButton(
                tooltip: 'Agregar recordatorio',
                onPressed: notesSnapshot.hasData &&
                        eventsSnapshot.hasData
                    ? () => _showReminderDialog(
                          notes: notesSnapshot.data!,
                          events: eventsSnapshot.data!,
                        )
                    : null,
                child: const Icon(Icons.add),
              );
            },
          );
        },
      ),
    );
  }
}
