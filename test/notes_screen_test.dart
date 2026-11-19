import 'dart:async';

import 'package:app_modular/modules/app/models/note_model.dart';
import 'package:app_modular/modules/app/screens/notes_screen.dart';
import 'package:app_modular/modules/app/services/note_service.dart';
import 'package:app_modular/modules/news/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('editar y eliminar una nota actualiza la lista', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final themeProvider = AppProvider();
    await themeProvider.loadTheme();

    final noteService = _FakeNoteService();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppProvider>.value(
        value: themeProvider,
        child: MaterialApp(home: NotesScreen(noteService: noteService)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar nota'));
    await tester.pumpAndSettle();

    expect(find.text('Editar nota'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Título actualizado');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(noteService.notes.single.title, 'Título actualizado');
    expect(find.text('Título actualizado'), findsOneWidget);

    await tester.tap(find.byTooltip('Eliminar nota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(noteService.notes, isEmpty);
    expect(find.text('Título actualizado'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    noteService.dispose();
    themeProvider.dispose();
  });
}

class _FakeNoteService implements NoteService {
  final StreamController<List<NoteModel>> _controller =
      StreamController<List<NoteModel>>.broadcast(sync: true);

  final List<NoteModel> notes = [
    NoteModel(
      id: 'note-1',
      title: 'Nota de prueba',
      content: 'Contenido inicial',
      pinned: false,
      createdAt: DateTime(2026),
    ),
  ];

  @override
  Stream<List<NoteModel>> watchNotes() async* {
    yield List.unmodifiable(notes);
    yield* _controller.stream;
  }

  @override
  Future<String> createNote({
    required String title,
    required String content,
    bool pinned = false,
  }) async {
    const id = 'note-new';
    notes.add(
      NoteModel(
        id: id,
        title: title,
        content: content,
        pinned: pinned,
        createdAt: DateTime.now(),
      ),
    );
    _controller.add(List.unmodifiable(notes));
    return id;
  }

  @override
  Future<List<NoteModel>> getNotes() async => List.unmodifiable(notes);

  @override
  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
    required bool pinned,
  }) async {
    final index = notes.indexWhere((note) => note.id == noteId);
    final note = notes[index];
    notes[index] = NoteModel(
      id: note.id,
      title: title,
      content: content,
      pinned: pinned,
      createdAt: note.createdAt,
    );
    _controller.add(List.unmodifiable(notes));
  }

  @override
  Future<void> deleteNote(String noteId) async {
    notes.removeWhere((note) => note.id == noteId);
    _controller.add(List.unmodifiable(notes));
  }

  void dispose() {
    _controller.close();
  }
}
