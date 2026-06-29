import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dummy_data.dart';
import '../models/booking.dart';

/// Exposes the student's bookings to the UI.
///
/// Bookings are this app's ONE CRUD entity (tutors are read-only dummy data).
/// Part 2: returns the in-memory [kDummyBookings] list so the My Bookings
/// screen renders without a backend.
/// Part 3: this becomes a Firestore StreamProvider (living alongside the auth
/// providers in firebase_provider.dart) filtered by the signed-in user — the
/// UI reading it won't need to change.
final bookingsProvider = Provider<List<Booking>>((ref) => kDummyBookings);
