import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

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

  /*
  
    CREATE

  */

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

  // upload profile picture
  Future<void> uploadProfilePicture({
    required String userId,
    required String filePath,
  }) async {
    await _usersCollection.doc(userId).update({
      'profilePicture': filePath,
    });
  }

  // create pin
  Future<void> createPin({
    required LocationData currentLocation,
    required String markerTitle,
    required double markerColor,
  }) async {
    await FirebaseFirestore.instance.collection('pins').add({
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
      'title': markerTitle,
      'color': markerColor.toDouble(), // Ensure color is stored as double
      'timestamp': FieldValue.serverTimestamp(),
      'yesVotes': 0,
      'noVotes': 0,
    });
  }

  /*

    READ

  */

  // get universities
  Future<List<Map<String, dynamic>>> getUniversities() async {
    final QuerySnapshot universities =
        await FirebaseFirestore.instance.collection('universities').get();
    return universities.docs
        .map((DocumentSnapshot doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // get user's university
  Future<String> getUserUniversity({required String userId}) async {
    try {
      final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
      return userDoc.get('university');
    } catch (e) {
      return "";
    }
  }

  // get buildings
  Future<List<dynamic>> getBuildings({
    required String userId,
  }) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();

    if (!userDoc.exists) {
      throw Exception('User not found');
    }

    final String university = userDoc.get('university');

    final DocumentSnapshot universityDoc = await FirebaseFirestore.instance
        .collection('universities')
        .doc(university)
        .get();

    if (!universityDoc.exists) {
      throw Exception('University not found');
    }

    return universityDoc.get('buildings');
  }

  // get classes
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

  // get profile picture
  Future<String> getProfilePicture({required String userId}) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
    final String profilePicture = userDoc.get('profilePicture');
    return profilePicture;
  }

  // check if the user is an adimin
  Future<bool> isAdmin({required String userId}) async {
    final DocumentSnapshot userDoc = await _usersCollection.doc(userId).get();
    final bool? isAdmin = userDoc.get('isAdmin');

    return isAdmin ?? false;
  }

  /*

    UPDATE

  */

  // update user password
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

  // update user's preferred university
  Future<void> updateUserUniversity({
    required String userId,
    required String university,
  }) async {
    await _usersCollection.doc(userId).update({
      'university': university,
    });
  }

  // update pins
  Future<void> updatePins({
    required String markerId,
    required bool isYesVote,
  }) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('pins').doc(markerId);
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Marker does not exist!");
      }

      int newYesVotes = snapshot['yesVotes'];
      int newNoVotes = snapshot['noVotes'];

      if (isYesVote) {
        newYesVotes += 1;
      } else {
        newNoVotes += 1;
      }

      if (newNoVotes > 5) {
        transaction.delete(docRef);
      } else {
        transaction.update(docRef, {
          'yesVotes': newYesVotes,
          'noVotes': newNoVotes,
          'lastActivity': FieldValue.serverTimestamp()
        });
      }
    });
  }

  /*

    // DELETE

  */

  Future<void> deleteClassFromDatabase({
    required String userId,
    required Map<String, dynamic> userClass,
  }) async {
    await _usersCollection.doc(userId).update({
      'classes': FieldValue.arrayRemove([userClass]),
    });
  }

  // delete user data
  Future<void> deleteUserData(String userId) async {
    await _usersCollection.doc(userId).delete();
  }

  // delete expired pins
  Future<void> deleteExpiredPins({required DateTime expirationTime}) async {
    FirebaseFirestore.instance
        .collection('pins')
        .where('lastActivity', isLessThan: expirationTime)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    }).catchError((error) {
      throw Exception('Error deleting expired pins: $error');
    });
  }
}
