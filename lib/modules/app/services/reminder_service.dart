
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/reminder_model.dart';

class ReminderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _remindersCollection(
    String uid,
  ) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('reminders');
  }

  String _requireUid() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'Debes iniciar sesión para administrar recordatorios.',
      );
    }

    return user.uid;
  }

  void _validateDate(DateTime scheduledAt) {
    if (!scheduledAt.isAfter(DateTime.now())) {
      throw Exception(
        'La fecha y hora deben ser posteriores al momento actual.',
      );
    }
  }

  Future<String> createReminder({
    required DateTime scheduledAt,
    String? eventId,
    String? noteId,
  }) async {
    final uid = _requireUid();

    _validateDate(scheduledAt);

    final doc = await _remindersCollection(uid).add({
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'eventId': eventId,
      'noteId': noteId,
    });

    return doc.id;
  }

  Future<List<ReminderModel>> getReminders() async {
    final uid = _requireUid();

    final snapshot = await _remindersCollection(uid)
        .orderBy('scheduledAt')
        .get();

    return snapshot.docs.map((doc) {
      return ReminderModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<ReminderModel>> watchReminders() {
    final uid = _requireUid();

    return _remindersCollection(uid)
        .orderBy('scheduledAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReminderModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateReminder({
    required String reminderId,
    required DateTime scheduledAt,
    String? eventId,
    String? noteId,
  }) async {
    final uid = _requireUid();

    _validateDate(scheduledAt);

    await _remindersCollection(uid).doc(reminderId).update({
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'eventId': eventId,
      'noteId': noteId,
    });
  }

  Future<void> deleteReminder(String reminderId) async {
    final uid = _requireUid();

    await _remindersCollection(uid).doc(reminderId).delete();
  }
}
