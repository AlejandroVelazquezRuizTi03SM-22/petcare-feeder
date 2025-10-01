import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Guarda el nombre en Firestore (colección: users, doc: uid)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({'name': name, 'email': email});

    return cred;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: popup nativo de Firebase Auth
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    } else {
      // Android/iOS: GoogleSignIn -> credencial
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Operación cancelada',
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      return _auth.signInWithCredential(credential);
    }
  }
}
