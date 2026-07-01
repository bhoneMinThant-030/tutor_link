/// A tutor shown in the app.
///
/// For Part 2 these come from in-memory dummy data (see data/dummy_data.dart).
/// Part 3 will load them from Cloud Firestore instead. The field names match
/// the planned Firestore `tutors` document so the Part 3 mapping is a direct
/// swap.
class Tutor {
  final String tutorId;
  final String name;
  final String course; // the tutor's own course, e.g. "Computer Engineering"
  final String bio;
  final double hourlyRate; // SGD per hour
  final double rating; // 0.0 - 5.0
  final bool isActive; // hidden from listings when false (used in Part 3)
  final List<String> subjects; // e.g. ['COMT', 'MATHS']
  final List<String> availableDays; // e.g. ['Mon', 'Wed', 'Sat'] — filterable
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
}
