import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _eventsCollection(String uid) {
    return _db.collection('users').doc(uid).collection('events');
  }

  String _requireUid() {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Debes iniciar sesión para administrar eventos.');
    }

    return user.uid;
  }

  Future<String> createEvent({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uid = _requireUid();

    _validateDates(startDate, endDate);

    final doc = await _eventsCollection(uid).add({
      'title': title.trim(),
      'description': description.trim(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    });

    return doc.id;
  }

  Future<List<EventModel>> getEvents() async {
    final uid = _requireUid();

    final snapshot = await _eventsCollection(uid).orderBy('startDate').get();

    return snapshot.docs.map((doc) {
      return EventModel.fromMap(doc.id, doc.data());
    }).toList();
  }

  Stream<List<EventModel>> watchEvents() {
    final uid = _requireUid();

    return _eventsCollection(uid)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return EventModel.fromMap(doc.id, doc.data());
          }).toList();
        });
  }

  Future<void> updateEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uid = _requireUid();

    _validateDates(startDate, endDate);

    await _eventsCollection(uid).doc(eventId).update({
      'title': title.trim(),
      'description': description.trim(),
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    });
  }

  Future<void> deleteEvent(String eventId) async {
    final uid = _requireUid();

    await _eventsCollection(uid).doc(eventId).delete();
  }

  void _validateDates(DateTime startDate, DateTime endDate) {
    if (!endDate.isAfter(startDate)) {
      throw Exception(
        'La fecha y hora de finalización debe ser posterior al inicio.',
      );
    }
  }
}
