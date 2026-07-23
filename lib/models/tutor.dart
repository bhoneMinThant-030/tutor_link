import 'package:cloud_firestore/cloud_firestore.dart';

/// A tutor shown in the app.
///
/// For Part 2 these came from in-memory dummy data (see data/dummy_data.dart).
/// Part 3 loads them from Cloud Firestore instead. The field names match the
/// Firestore `tutors` document so the mapping is a direct swap.
class Tutor {
  final String tutorId;
  final String name;
  final String course; // the tutor's own course, e.g. "Computer Engineering"
  final String bio;
  final double hourlyRate; // SGD per hour
  final double rating; // 0.0 - 5.0
  final bool isActive; // hidden from listings when false (used in Part 3)
  final List<String> subjects; // e.g. ['COMT', 'LOMA']
  final List<String> availableDays; // e.g. ['Mon', 'Wed', 'Sat'] (filterable)
  final String? photoUrl; // null -> placeholder avatar

  const Tutor({
    required this.tutorId,
    required this.name,
    required this.course,
    required this.bio,
    required this.hourlyRate,
    required this.rating,
    required this.isActive,
    required this.subjects,
    required this.availableDays,
    this.photoUrl,
  });

  /// Builds a [Tutor] from a Firestore document. The document ID is the
  /// tutorId; the rest come from the document's fields. Missing values fall
  /// back to sensible defaults so a malformed document never crashes the UI.
  static Tutor fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Tutor(
      tutorId: doc.id,
      name: data['name'] ?? '',
      course: data['course'] ?? '',
      bio: data['bio'] ?? '',
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      isActive: data['isActive'] ?? true,
      subjects: List<String>.from(data['subjects'] ?? const []),
      availableDays: List<String>.from(data['availableDays'] ?? const []),
      photoUrl: data['photoUrl'],
    );
  }
}
