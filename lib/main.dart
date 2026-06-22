import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'widgets/main_scaffold.dart';

void main() {
  // ProviderScope is the root container that holds every Riverpod provider.
  // Any widget below it can read providers via `ref.watch` / `ref.read`.
  runApp(const ProviderScope(child: TutorLinkApp()));
}

/// Root widget of the TutorLINK application.
///
/// For now it shows the [MainScaffold] (the logged-in shell) directly so we can
/// build the UI first. In the authentication phase this `home:` will be replaced
/// by an auth gate that shows the login screen when no user is signed in.
class TutorLinkApp extends StatelessWidget {
  const TutorLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TutorLINK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainScaffold(),
    );
  }
}
