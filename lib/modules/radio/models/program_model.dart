
class ProgramModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String stationId;
  final String schedule;
  final String host;

  const ProgramModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.stationId,
    required this.schedule,
    required this.host,
  });

  factory ProgramModel.fromMap(Map<String, dynamic> map) {
    return ProgramModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      stationId: map['stationId'] ?? '',
      schedule: map['schedule'] ?? '',
      host: map['host'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'stationId': stationId,
      'schedule': schedule,
      'host': host,
    };
  }
}
