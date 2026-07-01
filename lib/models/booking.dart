import 'package:flutter/material.dart';

/// Status of a booking, with a display label and badge colour.
enum BookingStatus {
  confirmed,
  pending;

  String get label => switch (this) {
    BookingStatus.confirmed => 'CONFIRMED',
    BookingStatus.pending => 'PENDING',
  };

  Color get color => switch (this) {
    BookingStatus.confirmed => const Color(0xFFD32F2F),
    BookingStatus.pending => Colors.grey,
  };
}

/// A booking shown on the My Bookings screen — the app's ONE CRUD entity.
///
/// For Part 2 these come from in-memory dummy data (see data/dummy_data.dart).
/// The field names match the planned Firestore `bookings` document, so Part 3
/// swaps to real Firestore reads/writes without changing the UI.
class Booking {
  final String bookingId;
  final String studentId; // FK to the signed-in user (placeholder in Part 2)
  final String tutorId; // FK to the tutor
  final String tutorName; // denormalised copy of the tutor's name for display
  final String subject;
  final DateTime sessionDate; // date of the session (real date, not a label)
  final TimeOfDay timeFrom;
  final TimeOfDay timeTo;
  final String location;
  final double amount; // SGD total for the session
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.bookingId,
    required this.studentId,
    required this.tutorId,
    required this.tutorName,
    required this.subject,
    required this.sessionDate,
    required this.timeFrom,
    required this.timeTo,
    required this.location,
    required this.amount,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// A session is "upcoming" if its date is in the future. Computed from
  /// [sessionDate] rather than stored, so it is always correct — this drives
  /// the Upcoming / Past tabs on the bookings screen.
  bool get isUpcoming => sessionDate.isAfter(DateTime.now());
}
