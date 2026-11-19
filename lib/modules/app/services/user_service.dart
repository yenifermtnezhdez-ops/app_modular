import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserModel> getOrCreateProfile(User user) async {
    final docRef = _db.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final profile = UserModel.fromMap(data);

      final updatedProfile = UserModel(
        uid: user.uid,
        email: user.email ?? profile.email,
        displayName: profile.displayName.isNotEmpty
            ? profile.displayName
            : (user.displayName ?? ''),
        displayImage: profile.displayImage,
      );

      await docRef.set(updatedProfile.toMap(), SetOptions(merge: true));

      return updatedProfile;
    }

    final profile = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      displayImage: '',
    );

    await docRef.set(profile.toMap());

    return profile;
  }

  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String displayImage,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'displayName': displayName.trim(),
      'displayImage': displayImage.trim(),
    }, SetOptions(merge: true));
  }
}
