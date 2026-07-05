import 'package:flutter/material.dart';

import '../models/tutor.dart';
import 'rating_label.dart';
import 'subject_tag.dart';
import 'tutor_avatar.dart';

/// Card shown in the "Top Tutors" list on the Home screen.
///
/// Tapping the card opens the tutor's profile; the button starts a booking.
class TutorCard extends StatelessWidget {
  final Tutor tutor;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const TutorCard({
    super.key,
    required this.tutor,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      // InkWell instead of a plain GestureDetector so tapping the whole
      // card shows a ripple, giving feedback on this large tap target.
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TutorAvatar(tutor: tutor, size: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tutor.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        RatingLabel(rating : tutor.rating),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Subject tags wrap to a new line if there are many.
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: 
                      [...tutor.subjects.map((subj) => SubjectTag(label: subj))]
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${tutor.hourlyRate.toStringAsFixed(0)}/hr',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        ElevatedButton(
                          onPressed: onBook,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Book session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
