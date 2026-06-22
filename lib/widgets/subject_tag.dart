import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small red-outlined chip showing a subject a tutor teaches (e.g. COMT).
class SubjectTag extends StatelessWidget {
  final String label;

  const SubjectTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.brandRed),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.brandRed,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
