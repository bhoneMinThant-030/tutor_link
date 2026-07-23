import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'providers/firebase_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase must be initialised before any Firebase call (auth, Firestore).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ProviderScope is the root container that holds every Riverpod provider.
  runApp(const ProviderScope(child: TutorLinkApp()));
}

/// Root widget of the TutorLINK application.
///
/// Acts as the auth gate: it watches [authStateProvider] and shows the app
/// shell when a user is signed in, or the login screen when not. Because this
/// listens to Firebase, login and logout switch screens automatically without
/// any manual navigation.
class TutorLinkApp extends ConsumerWidget {
  const TutorLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'TutorLINK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: authState.when(
        data: (user) =>
            user != null ? const MainScaffold() : const LoginScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) =>
            const Scaffold(body: Center(child: Text('Something went wrong'))),
      ),
    );
  }
}
