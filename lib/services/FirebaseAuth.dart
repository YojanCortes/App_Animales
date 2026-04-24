import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualiza el nombre de usuario en Firebase Authentication
      await updateDisplayName(displayName);

      return null; // Registro exitoso, devuelve null
    } on FirebaseAuthException catch (e) {
      return e
          .message; // Devuelve un mensaje de error específico en caso de falla
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Inicio de sesión exitoso, devuelve null
    } on FirebaseAuthException catch (e) {
      return e
          .message; // Devuelve un mensaje de error específico en caso de falla
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Error during sign out: $e");
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  String? getCurrentUserId() {
    return null;
  }
}
