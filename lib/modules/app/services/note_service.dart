import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/note_model.dart';

class NoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _notesCollection(String uid) {
    return _db.collection('users').doc(uid).collection('notes');
  }

  String _requireUid() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Debes iniciar sesión para usar tus notas.');
    }

    return user.uid;
  }

  Future<String> createNote({
    required String title,
    required String content,
    bool pinned = false,
  }) async {
    final uid = _requireUid();

    final doc = await _notesCollection(uid).add({
      'title': title.trim(),
      'content': content.trim(),
      'pinned': pinned,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<List<NoteModel>> getNotes() async {
    final uid = _requireUid();

    final snapshot = await _notesCollection(uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return NoteModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<NoteModel>> watchNotes() {
    final uid = _requireUid();

    return _notesCollection(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NoteModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> updateNote({
    required String noteId,
    required String title,
    required String content,
    required bool pinned,
  }) async {
    final uid = _requireUid();

    await _notesCollection(uid).doc(noteId).update({
      'title': title.trim(),
      'content': content.trim(),
      'pinned': pinned,
    });
  }

  Future<void> deleteNote(String noteId) async {
    final uid = _requireUid();

    await _notesCollection(uid).doc(noteId).delete();
  }
}
