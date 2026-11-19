import 'package:flutter/material.dart';

import '../../../app/theme_toggle_button.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final EventService _eventService = EventService();

  late final Stream<List<EventModel>> _eventsStream;

  @override
  void initState() {
    super.initState();
    _eventsStream = _eventService.watchEvents();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  Future<void> _showEventDialog({EventModel? event}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          _EventEditorDialog(event: event, eventService: _eventService),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            event == null
                ? 'Evento creado correctamente.'
                : 'Evento actualizado correctamente.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteEvent(EventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar evento'),
          content: Text('¿Deseas eliminar "${event.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _eventService.deleteEvent(event.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento eliminado correctamente')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el evento: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis eventos'),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _eventsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Ocurrió un error al cargar los eventos:\n'
                  '${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.event_note, size: 64),
                    SizedBox(height: 12),
                    Text(
                      'Todavía no tienes eventos.',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 8),
                    Text('Pulsa + para crear tu primer evento.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.event)),
                        title: Text(
                          event.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(event.description),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_arrow),
                        title: const Text('Inicio'),
                        subtitle: Text(_formatDate(event.startDate)),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.stop),
                        title: const Text('Finalización'),
                        subtitle: Text(_formatDate(event.endDate)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: 'Editar evento',
                            onPressed: () {
                              _showEventDialog(event: event);
                            },
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            tooltip: 'Eliminar evento',
                            onPressed: () {
                              _deleteEvent(event);
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showEventDialog();
        },
        tooltip: 'Agregar evento',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EventEditorDialog extends StatefulWidget {
  final EventModel? event;
  final EventService eventService;

  const _EventEditorDialog({required this.event, required this.eventService});

  @override
  State<_EventEditorDialog> createState() => _EventEditorDialogState();
}

class _EventEditorDialogState extends State<_EventEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  late DateTime _startDate;
  late DateTime _endDate;

  bool _saving = false;
  String? _dateError;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.event?.title ?? '');

    _descriptionController = TextEditingController(
      text: widget.event?.description ?? '',
    );

    _startDate =
        widget.event?.startDate ?? DateTime.now().add(const Duration(hours: 1));

    _endDate =
        widget.event?.endDate ?? DateTime.now().add(const Duration(hours: 2));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  Future<DateTime?> _pickDateTime(DateTime initialDate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || !mounted) {
      return null;
    }

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (selectedTime == null || !mounted) {
      return null;
    }

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _selectStartDate() async {
    if (_saving) return;

    final selected = await _pickDateTime(_startDate);

    if (!mounted || selected == null) return;

    setState(() {
      _startDate = selected;
      _dateError = null;
    });
  }

  Future<void> _selectEndDate() async {
    if (_saving) return;

    final selected = await _pickDateTime(_endDate);

    if (!mounted || selected == null) return;

    setState(() {
      _endDate = selected;
      _dateError = null;
    });
  }

  Future<void> _saveEvent() async {
    if (_saving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_endDate.isAfter(_startDate)) {
      setState(() {
        _dateError = 'La finalización debe ser posterior al inicio.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _dateError = null;
    });

    try {
      final event = widget.event;

      if (event == null) {
        await widget.eventService.createEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await widget.eventService.updateEvent(
          eventId: event.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _dateError = 'No se pudo guardar el evento: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Nuevo evento' : 'Editar evento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Nombre del evento',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe el nombre del evento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                enabled: !_saving,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Escribe una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month),
                title: const Text('Inicio'),
                subtitle: Text(_formatDate(_startDate)),
                onTap: _selectStartDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available),
                title: const Text('Finalización'),
                subtitle: Text(_formatDate(_endDate)),
                onTap: _selectEndDate,
              ),
              if (_dateError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _dateError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.of(context).pop(false);
                },
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveEvent,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
