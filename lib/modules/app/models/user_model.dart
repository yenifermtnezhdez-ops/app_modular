class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String displayImage;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.displayImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'displayImage': displayImage,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      displayImage: map['displayImage']?.toString() ?? '',
    );
  }
}
