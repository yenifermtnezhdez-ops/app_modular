
class StationModel {
  final String id;
  final String name;
  final String acronym;
  final String slogan;
  final String streamUrl;
  final String imageUrl;
  final String description;
  final String category;
  final String frequency;
  final String websiteUrl;
  final String xUrl;
  final String instagramUrl;

  const StationModel({
    required this.id,
    required this.name,
    required this.acronym,
    required this.slogan,
    required this.streamUrl,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.frequency,
    this.websiteUrl = '',
    this.xUrl = '',
    this.instagramUrl = '',
  });

  factory StationModel.fromMap(Map<String, dynamic> map) {
    return StationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      acronym: map['acronym'] ?? '',
      slogan: map['slogan'] ?? '',
      streamUrl: map['streamUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      frequency: map['frequency'] ?? '',
      websiteUrl: map['websiteUrl'] ?? '',
      xUrl: map['xUrl'] ?? '',
      instagramUrl: map['instagramUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'acronym': acronym,
      'slogan': slogan,
      'streamUrl': streamUrl,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'frequency': frequency,
      'websiteUrl': websiteUrl,
      'xUrl': xUrl,
      'instagramUrl': instagramUrl,
    };
  }
}
