import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  // Unique App ID for storage isolation
  static const String appId = 'pondstat-app-v1';

  /// Returns the reference to the Users collection
  /// Path: /artifacts/{appId}/public/data/users
  static CollectionReference<Map<String, dynamic>> get usersCollection {
    return FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('users');
  }

  /// Returns the reference to the Measurements collection
  /// Path: /artifacts/{appId}/public/data/measurements
  static CollectionReference<Map<String, dynamic>> get measurementsCollection {
    return FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('measurements');
  }
}