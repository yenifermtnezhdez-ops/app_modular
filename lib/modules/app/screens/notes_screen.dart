import 'package:flutter/material.dart';

import '../../../app/theme_toggle_button.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NotesScreen extends StatefulWidget {
  final NoteService? noteService;

  const NotesScreen({super.key, this.noteService});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NoteService _noteService;
  late final Stream<List<NoteModel>> _notesStream;

  @override
  void initState() {
    super.initState();
    _noteService = widget.noteService ?? NoteService();
    _notesStream = _noteService.watchNotes();
  }

  Future<void> _openNoteDialog({NoteModel? note}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _NoteEditorDialog(note: note, noteService: _noteService),
    );

    if (!mounted) return;

    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            note == null
                ? 'Nota creada correctamente.'
                : 'Nota actualizada correctamente.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Seguro que deseas eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _noteService.deleteNote(note.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nota eliminada correctamente.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo eliminar la nota: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis notas'),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<NoteModel>>(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error al cargar las notas:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = List<NoteModel>.of(snapshot.data ?? const []);

          notes.sort((a, b) {
            if (a.pinned != b.pinned) {
              return a.pinned ? -1 : 1;
            }

            return b.createdAt.compareTo(a.createdAt);
          });

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Todavía no tienes notas.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text('Pulsa + para crear tu primera nota.'),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    note.pinned ? Icons.push_pin : Icons.note_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    note.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      note.content.isEmpty ? 'Sin contenido' : note.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onTap: () {
                    _openNoteDialog(note: note);
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar nota',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _openNoteDialog(note: note),
                      ),
                      IconButton(
                        tooltip: 'Eliminar nota',
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => _deleteNote(note),
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
          _openNoteDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NoteEditorDialog extends StatefulWidget {
  final NoteModel? note;
  final NoteService noteService;

  const _NoteEditorDialog({required this.note, required this.noteService});

  @override
  State<_NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends State<_NoteEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  late bool _pinned;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');

    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );

    _pinned = widget.note?.pinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      setState(() {
        _errorMessage = 'Escribe un título para la nota.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final note = widget.note;

      if (note == null) {
        await widget.noteService.createNote(
          title: title,
          content: content,
          pinned: _pinned,
        );
      } else {
        await widget.noteService.updateNote(
          noteId: note.id,
          title: title,
          content: content,
          pinned: _pinned,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _errorMessage = 'No se pudo guardar la nota: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Nueva nota' : 'Editar nota'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              enabled: !_saving,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Contenido',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fijar nota'),
              value: _pinned,
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(() {
                        _pinned = value ?? false;
                      });
                    },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
          ],
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
        ElevatedButton(
          onPressed: _saving ? null : _saveNote,
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
