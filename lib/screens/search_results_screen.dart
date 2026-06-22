import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/tutor.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_label.dart';
import '../widgets/tutor_avatar.dart';
import 'booking_form_screen.dart';
import 'tutor_profile_screen.dart';

/// Shows the top tutor matches "returned by" the AI search.
///
/// Part 2 uses sample data with fixed reasons; Part 3 populates this from the
/// LLM response (top 3 tutors, each with a short reasoning line).
class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  // Sample reasoning lines (Part 3 receives these from the AI).
  static const _reasons = [
    'Your availability with this tutor matches',
    'Your project advancement matches with this tutor.',
    'Your thinking style match with this tutor',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TutorLINK')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppTheme.brandRed, size: 16),
              SizedBox(width: 6),
              Text(
                'AI MATCHING ENGINE',
                style: TextStyle(
                  color: AppTheme.brandRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Your matches',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on your learning style and curriculum goals.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < kDummyTutors.length; i++)
            _MatchCard(
              tutor: kDummyTutors[i],
              reason: _reasons[i % _reasons.length],
            ),
        ],
      ),
    );
  }
}

/// One AI-match result: tutor summary, reasoning line and two actions.
class _MatchCard extends StatelessWidget {
  final Tutor tutor;
  final String reason;

  const _MatchCard({required this.tutor, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TutorAvatar(tutor: tutor, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tutor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        tutor.course,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${tutor.hourlyRate.toStringAsFixed(0)} /hr',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                RatingLabel(tutor.rating),
              ],
            ),
            const SizedBox(height: 10),
            // The AI's reason for this match.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                reason,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TutorProfileScreen(tutor: tutor),
                      ),
                    ),
                    child: const Text('VIEW PROFILE'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingFormScreen(tutor: tutor),
                      ),
                    ),
                    child: const Text('BOOK SESSION'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
