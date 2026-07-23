import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_link/models/booking.dart';

/// Wraps the Firebase Authentication SDK so the UI never talks to Firebase
/// directly. Screens call these methods through [firebaseServiceProvider].
///
/// Covers email/password auth (register, login, logout, reset), account
/// management (change password, email verification) and the additional
/// sign-in methods (phone/OTP, Google). Part 3 adds Firestore CRUD here.
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
      // Left empty on purpose. If auto retrieval times out, the user can
      // still type the code by hand, so there's nothing extra to do here.
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

  /// Signs in with Google. Opens the Google account picker, converts the
  /// returned Google tokens into a Firebase credential, and signs in.
  /// Returns null if the user dismisses the picker.
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(
      // The Web client ID. On Android this is passed as serverClientId so
      // Google returns an idToken whose audience Firebase accepts. This is a
      // public identifier, not a secret, so it's fine to check into source.
      clientId:
          '1082566953133-s97f7svm66adjvqdigs5pj5hi89d4lcf.apps.googleusercontent.com',
    ).signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Saves the user's profile (name, course, year) to Firestore, keyed by
  /// their UID so it links to the Authentication record. Called right after
  /// register(); powers the Part 3 recommendation engine.
  Future<void> addUserInfo(
    String uid,
    String name,
    String course,
    int yearOfStudy,
  ) {
    return FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'course': course,
      'yearOfStudy': yearOfStudy,
    });
  }

  /// Creates a new booking document in the `bookings` collection. Firestore
  /// auto-generates the document ID; [Booking.toMap] handles serialisation.
  Future<void> addBooking(Booking booking) {
    return FirebaseFirestore.instance
        .collection('bookings')
        .add(booking.toMap());
  }
}
