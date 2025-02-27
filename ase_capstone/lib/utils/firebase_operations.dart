import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // CREATE
  Future<void> addUserToDatabase(
      {required String uid, required String email, required password}) async {
    await _usersCollection.doc(uid).set({
      'email': email,
      'password': password,
    });
  }
  // READ

  // UPDATE

  // DELETE
}
