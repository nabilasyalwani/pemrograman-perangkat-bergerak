import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> addScanToHistory(Map<String, dynamic> scanResult) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('scanHistory')
          .add(scanResult);
    } catch (e) {
      throw Exception('Failed to save to database: $e');
    }
  }

  Stream<QuerySnapshot> getScanHistory() {
    final user = _currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('scanHistory')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteScanFromHistory(String scanId) async {
    final user = _currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('scanHistory')
        .doc(scanId)
        .delete();
  }
}
