import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // CREATE
  Future<void> addUserToDatabase(
      {required String email, required password}) async {
    await _usersCollection.add({
      'email': email,
      'password': password,
    });
  }
  // READ

  // UPDATE

  // DELETE
}
