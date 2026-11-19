import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final DateTime scheduledAt;
  final String? eventId;
  final String? noteId;

  const ReminderModel({
    required this.id,
    required this.scheduledAt,
    this.eventId,
    this.noteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'eventId': eventId,
      'noteId': noteId,
    };
  }

  factory ReminderModel.fromMap(String id, Map<String, dynamic> map) {
    final scheduledAt = map['scheduledAt'];

    return ReminderModel(
      id: id,
      scheduledAt: scheduledAt is Timestamp
          ? scheduledAt.toDate()
          : DateTime.now(),
      eventId: map['eventId'] as String?,
      noteId: map['noteId'] as String?,
    );
  }
}
