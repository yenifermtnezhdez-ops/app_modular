class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String displayImage;
  final List<String> favoriteStations;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.displayImage,
    this.favoriteStations = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'displayImage': displayImage,
      'favoriteStations': favoriteStations,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      displayImage: map['displayImage']?.toString() ?? '',
      favoriteStations: (map['favoriteStations'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
