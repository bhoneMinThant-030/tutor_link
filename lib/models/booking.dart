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

/// A booking shown on the My Bookings screen.
///
/// Dummy data for Part 2 (dates are pre-formatted strings to keep things
/// simple). Part 3 stores these in Firestore with real Timestamp fields.
class Booking {
  final String id;
  final String tutorName;
  final String course;
  final String subject;
  final String dateLabel; // e.g. "Jun 22, 2026"
  final String timeLabel; // e.g. "2:00PM-4:00PM"
  final String location;
  final BookingStatus status;
  final bool isUpcoming;

  const Booking({
    required this.id,
    required this.tutorName,
    required this.course,
    required this.subject,
    required this.dateLabel,
    required this.timeLabel,
    required this.location,
    required this.status,
    required this.isUpcoming,
  });
}
