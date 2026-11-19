
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'pinned': pinned,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NoteModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final timestamp = map['createdAt'];

    return NoteModel(
      id: id,
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
      pinned: map['pinned'] == true,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
    );
  }
}
