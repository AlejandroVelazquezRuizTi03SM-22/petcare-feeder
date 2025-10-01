import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserDataAdapter {
  Stream<String?> watchDisplayName(String uid); // OBSERVER: nombre reactivo
}

class FirestoreUserDataAdapter implements UserDataAdapter {
  final _db = FirebaseFirestore.instance;

  @override
  Stream<String?> watchDisplayName(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final data = snap.data()!;
      return (data['name'] as String?) ?? (data['displayName'] as String?);
    });
  }
}
