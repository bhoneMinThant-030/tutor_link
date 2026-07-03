import 'package:firebase_auth/firebase_auth.dart';

/// Maps Firebase auth error codes to short, user-friendly messages so every
/// screen reports errors the same way. Unmapped codes fall back to Firebase's
/// own message, so unexpected errors are never hidden.
String friendlyAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'weak-password':
      return 'Password must be at least 6 characters.';
    case 'invalid-phone-number':
      return 'Please enter a valid phone number (e.g. +6591234567).';
    case 'invalid-verification-code':
      return 'Incorrect code. Please try again.';
    case 'too-many-requests':
      return 'Too many attempts. Please try again later.';
    case 'network-request-failed':
      return 'No internet connection. Please try again.';
    default:
      return e.message ?? e.code;
  }
}
