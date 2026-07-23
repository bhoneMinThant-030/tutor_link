import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import 'firebase_provider.dart';

/// Streams the signed-in student's bookings from Firestore, newest activity
/// reflected live. Filtered by studentId so each user only sees their own.
final bookingsProvider = StreamProvider<List<Booking>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('bookings')
          .where('studentId', isEqualTo: user.uid)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList(),
          );
    },
    loading: () => Stream.value([]),
    error: (e, _) => Stream.value([]),
  );
});