import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_service.dart';

/// Exposes a single shared [FirebaseService] instance to the whole app.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

/// Streams the user's sign-in state from Firebase.
///
/// Emits a [User] when signed in, or null when signed out. `main.dart` watches
/// this to decide whether to show the app or the login screen, so login/logout
/// navigation happens automatically.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Like [authStateProvider] but also emits on user *updates*, including
/// `reload()` after email verification, so the UI can refresh `emailVerified`.
final userChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});
