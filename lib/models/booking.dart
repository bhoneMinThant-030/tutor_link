import 'package:cloud_firestore/cloud_firestore.dart';
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

/// A booking shown on the My Bookings screen (the app's ONE CRUD entity).
///
/// For Part 2 these come from in-memory dummy data (see data/dummy_data.dart).
/// The field names match the planned Firestore `bookings` document, so Part 3
/// swaps to real Firestore reads/writes without changing the UI.
class Booking {
  final String bookingId;
  final String studentId; // FK to the signed-in user (placeholder in Part 2)
  final String tutorId; // FK to the tutor
  final String tutorName; // denormalised copy of the tutor's name for display
  final String? tutorPhotoUrl; // denormalised copy of the tutor's photo, if any
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
    this.tutorPhotoUrl,
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
  /// [sessionDate] rather than stored, so it is always correct. This drives
  /// the Upcoming / Past tabs on the bookings screen.
  bool get isUpcoming => sessionDate.isAfter(DateTime.now());

  /// Builds a [Booking] from a Firestore document. Firestore stores dates as
  /// Timestamp and has no TimeOfDay/enum types, so those are converted here.
  static Booking fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return Booking(
      bookingId: doc.id,
      studentId: data['studentId'] ?? '',
      tutorId: data['tutorId'] ?? '',
      tutorName: data['tutorName'] ?? '',
      tutorPhotoUrl: data['tutorPhotoUrl'],
      subject: data['subject'] ?? '',
      sessionDate:
          (data['sessionDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeFrom: _timeFromString(data['timeFrom']),
      timeTo: _timeFromString(data['timeTo']),
      location: data['location'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      status: _statusFromString(data['status']),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Serialises this booking into a Firestore map. TimeOfDay → "HH:mm" string,
  /// enum → its name, DateTime → Timestamp. bookingId is omitted (Firestore's
  /// auto-generated document ID is the id on read).
  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'tutorPhotoUrl': tutorPhotoUrl,
      'subject': subject,
      'sessionDate': Timestamp.fromDate(sessionDate),
      'timeFrom': _timeToString(timeFrom),
      'timeTo': _timeToString(timeTo),
      'location': location,
      'amount': amount,
      'status': status.name,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// "HH:mm" ⇄ TimeOfDay, since Firestore has no time type.
String _timeToString(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay _timeFromString(String? s) {
  if (s == null) return const TimeOfDay(hour: 0, minute: 0);
  final parts = s.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Firestore stores the status as its name string ("confirmed"/"pending").
BookingStatus _statusFromString(String? s) => BookingStatus.values.firstWhere(
  (e) => e.name == s,
  orElse: () => BookingStatus.pending,
);
