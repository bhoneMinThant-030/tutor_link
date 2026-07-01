import 'package:firebase_auth/firebase_auth.dart';

/// Wraps the Firebase Authentication SDK so the UI never talks to Firebase
/// directly — screens call these methods through [firebaseServiceProvider].
///
/// Part 2: basic email/password auth (register, login, logout, reset).
/// Part 3 will add Firestore CRUD + Google Sign-in here.
class FirebaseService {
  /// Creates a new account, then stores the display name on the user.
  Future<UserCredential> register(
    String email,
    String password,
    String name,
  ) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await credential.user?.updateDisplayName(name);
    return credential;
  }

  /// Signs in with an existing email + password.
  Future<UserCredential> login(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// The currently signed-in user, or null if signed out.
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Signs the user out.
  Future<void> logOut() {
    return FirebaseAuth.instance.signOut();
  }

  /// Sends a password-reset email to the given address.
  Future<void> forgotPassword(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
