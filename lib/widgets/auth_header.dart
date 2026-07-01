import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The logo + "TutorLINK" + tagline block shown at the top of every auth screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.brandRed,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 10),
        const Text(
          'TutorLINK',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Elevate your academic journey with expert tutoring and '
          'modern learning tools.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
      ],
    );
  }
}

/// Small grey uppercase field label used above each auth text field.
class AuthLabel extends StatelessWidget {
  final String text;

  const AuthLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
