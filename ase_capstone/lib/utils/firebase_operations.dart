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

  // create user
  Future<void> addUserToDatabase({
    required String uid,
    required String email,
    required username,
  }) async {
    await _usersCollection.doc(uid).set({
      'email': email,
      'username': username,
    });
  }

  // READ
  Future<Map<String, dynamic>> getClassesFromDatabase(
      {required String userId}) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  // get user
  Future<Map<String, dynamic>> getUser({required String? userId}) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  // UPDATE
  Future<void> updateUserPassword({
    required String userId,
    required String password,
  }) async {
    await _usersCollection.doc(userId).update({
      'password': password,
    });
  }

  // create/add a class
  Future<void> addClassToDatabase({
    required String userId,
    required Map<String, dynamic> userClass,
  }) async {
    await _usersCollection.doc(userId).update({
      'classes': FieldValue.arrayUnion([userClass]),
    });
  }

  // DELETE
  Future<void> deleteClassFromDatabase({
    required String userId,
    required Map<String, dynamic> userClass,
  }) async {
    await _usersCollection.doc(userId).update({
      'classes': FieldValue.arrayRemove([userClass]),
    });
  }

  // DELETE USER
  Future<void> deleteUserData(String userId) async {
    await _usersCollection.doc(userId).delete();
  }
}
