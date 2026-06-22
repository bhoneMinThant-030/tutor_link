import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutor.dart';
import '../providers/tutors_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/tutor_card.dart';
import 'booking_form_screen.dart';
import 'tutor_profile_screen.dart';

/// Home tab: greeting, subject search box, the "Find My Tutor" AI banner and a
/// scrollable list of top tutors. Body-only (MainScaffold provides Scaffold).
///
/// Extends [ConsumerWidget] so it can read [tutorsProvider] via Riverpod.
class HomeScreen extends ConsumerWidget {
  /// Called when the AI banner is tapped; MainScaffold switches to the AI tab.
  final VoidCallback onStartAiSearch;

  const HomeScreen({super.key, required this.onStartAiSearch});

  void _openProfile(BuildContext context, Tutor tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TutorProfileScreen(tutor: tutor)),
    );
  }

  void _book(BuildContext context, Tutor tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingFormScreen(tutor: tutor)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the tutor list from the Riverpod provider. When the provider's
    // value changes (e.g. swapped for a Firestore stream in Part 3), Flutter
    // rebuilds this widget automatically.
    final tutors = ref.watch(tutorsProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Hello, Bhone.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to get your tutoring session?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Subject search box (visual only in Part 2).
        const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search by subject (e.g. Physics, Math)',
          ),
        ),
        const SizedBox(height: 16),

        // AI banner -> switches to the AI Search tab.
        _AiBanner(onTapAction: onStartAiSearch),
        const SizedBox(height: 20),

        const Text(
          'TOP TUTORS',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),

        // One card per tutor (from the Riverpod provider).
        ...tutors.map(
          (t) => TutorCard(
            tutor: t,
            onTap: () => _openProfile(context, t),
            onBook: () => _book(context, t),
          ),
        ),
      ],
    );
  }
}

/// The red "AI POWERED / Find My Tutor" banner on the Home screen.
class _AiBanner extends StatelessWidget {
  final VoidCallback onTapAction;

  const _AiBanner({required this.onTapAction});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.brandRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI POWERED',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find My Tutor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap:onTapAction,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical:8,horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start AI Search',
                      style: TextStyle(
                        color: AppTheme.brandRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: AppTheme.brandRed, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}
