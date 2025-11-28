import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmail(
    String email,
    String pass,
    String name,
  ) async {
    // Validación de correo electrónico
    if (!validateEmail(email)) {
      throw Exception("Correo electrónico no válido");
    }

    // Validación de contraseña segura
    if (!validatePassword(pass)) {
      throw Exception(
        "La contraseña debe tener al menos 8 caracteres, incluir letras y números",
      );
    }

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('consents').doc(cred.user!.uid).set({
      'consent': true,
      'timestamp': DateTime.now().toUtc(),
      'policyVersion': 'v1.0',
    });

    return cred;
  }

  Future<UserCredential> signInWithEmail(String email, String pass) {
    return _auth.signInWithEmailAndPassword(email: email, password: pass);
  }

  // Validación de formato de correo
  bool validateEmail(String email) {
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    return emailRegex.hasMatch(email);
  }

  // Validación de fortaleza de contraseña
  bool validatePassword(String pass) {
    final passRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&#]{8,}$');
    return passRegex.hasMatch(pass);
  }
}
