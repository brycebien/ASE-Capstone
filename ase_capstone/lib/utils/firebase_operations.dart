import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // CHECK IF USERNAME EXISTS VALIDATION
  Future<bool> checkUsernameExists({required String username}) async {
    final QuerySnapshot result = await _usersCollection
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }

  // CREATE
  Future<void> addUserToDatabase({
    required String uid,
    required String email,
    required username,
    required password,
  }) async {
    await _usersCollection.doc(uid).set({
      'email': email,
      'username': username,
      'password': password,
    });
  }
  // READ

  // UPDATE

  // DELETE
}
