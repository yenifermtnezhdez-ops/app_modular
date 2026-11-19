
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  factory EventModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final start = map['startDate'];
    final end = map['endDate'];

    return EventModel(
      id: id,
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startDate: start is Timestamp
          ? start.toDate()
          : DateTime.now(),
      endDate: end is Timestamp
          ? end.toDate()
          : DateTime.now(),
    );
  }
}
