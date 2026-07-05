import 'package:flutter/material.dart';

import '../models/tutor.dart';

/// Square rounded avatar for a tutor. Shows the tutor's photo when a photoUrl
/// is available, otherwise a neutral placeholder.
/// (Real photos/URLs are added in Part 3.)
class TutorAvatar extends StatelessWidget {
  final Tutor tutor;
  final double size;

  const TutorAvatar({super.key, required this.tutor, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFE0E0E0),
        // Most dummy tutors don't have a photoUrl set, guard against
        // Image.asset(null), which would throw. Part 2 photos are bundled
        // local assets so the demo doesn't depend on an external host being
        // reachable. Part 3 swaps this to Image.network for real Storage URLs.
        child: tutor.photoUrl == null
            ? const Icon(Icons.person, color: Colors.white, size: 32)
            : Image.asset(tutor.photoUrl!, fit: BoxFit.cover),
      ),
    );
  }
}
