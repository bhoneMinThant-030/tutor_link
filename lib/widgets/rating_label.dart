import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A star icon followed by the numeric rating, e.g. ★ 4.9.
///
/// The proposal noted star-only ratings are hard to read at a glance, so we
/// show the decimal number alongside the star.
class RatingLabel extends StatelessWidget {
  final double rating;

  const RatingLabel({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, color: AppTheme.brandRed, size: 16),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
