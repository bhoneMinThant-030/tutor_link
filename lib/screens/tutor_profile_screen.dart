import 'package:flutter/material.dart';

import '../models/tutor.dart';
import '../theme/app_theme.dart';
import '../widgets/subject_tag.dart';
import 'booking_form_screen.dart';

/// Full tutor profile: photo header, hourly rate, subjects, about and
/// availability, with a "Book session" call to action.
class TutorProfileScreen extends StatelessWidget {
  final Tutor tutor;

  const TutorProfileScreen({super.key, required this.tutor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TutorLINK')),
      body: ListView(
        children: [
          // Photo header with the name, rating and course overlaid.
          Stack(
            children: [
              Container(
                height: 240,
                width: double.infinity,
                color: const Color(0xFFE0E0E0),
                child: tutor.imageUrl == null
                    ? const Icon(Icons.person, size: 96, color: Colors.white)
                    : Image.network(tutor.imageUrl!, fit: BoxFit.cover),
              ),
              Positioned(
                left: 16,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppTheme.brandRed,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          tutor.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tutor.course,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hourly rate pill.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '\$${tutor.hourlyRate.toStringAsFixed(0)} /hr',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                const _SectionTitle('SUBJECTS'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...tutor.subjects.map((subj) => SubjectTag(label: subj)),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionTitle('ABOUT THE TUTOR'),
                const SizedBox(height: 6),
                Text(tutor.about),
                const SizedBox(height: 16),
                const _SectionTitle('AVAILABILITY'),
                const SizedBox(height: 6),
                Text(tutor.availability),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingFormScreen(tutor: tutor),
              ),
            ),
            child: const Text('Book session'),
          ),
        ),
      ),
    );
  }
}

/// Small red uppercase section heading used down the profile.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.brandRed,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}
