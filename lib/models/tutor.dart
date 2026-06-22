/// A tutor shown in the app.
///
/// For Part 2 these come from in-memory dummy data (see data/dummy_data.dart).
/// Part 3 will load them from Cloud Firestore instead.
class Tutor {
  final String id;
  final String name;
  final String course; // e.g. "Computer Engineering"
  final double hourlyRate; // SGD per hour
  final double rating; // 0.0 - 5.0
  final List<String> subjects; // e.g. ['COMT', 'MATHS']
  final String about;
  final String availability;
  final String? imageUrl; // null -> placeholder avatar

  const Tutor({
    required this.id,
    required this.name,
    required this.course,
    required this.hourlyRate,
    required this.rating,
    required this.subjects,
    required this.about,
    required this.availability,
    this.imageUrl,
  });
}
