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
    // Send the verification email as part of sign-up.
    await credential.user?.sendEmailVerification();
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

  /// Changes the signed-in user's password.
  ///
  /// Firebase requires a recent login before a password change, so we first
  /// re-authenticate with the current password, then set the new one. Works
  /// regardless of whether the account's email is verified.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user with a password.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// (Re)sends a verification email to the current user.
  Future<void> sendEmailVerification() async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user so `emailVerified` reflects the latest state
  /// (needed after the user clicks the link in the verification email).
  Future<void> reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
  }

  /// Starts phone-number verification: sends an SMS code (or matches a test
  /// number). The callbacks report each stage back to the UI.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onFailed,
  }) {
    return FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      // Android may auto-retrieve the code and sign in without user input.
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: onFailed,
      codeSent: (verificationId, resendToken) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  /// Signs in with the SMS code the user entered.
  Future<UserCredential> signInWithSmsCode(
    String verificationId,
    String smsCode,
  ) {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }
}
