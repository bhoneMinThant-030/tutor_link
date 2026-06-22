import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dummy_data.dart';
import '../models/tutor.dart';

/// Exposes the list of tutors to the UI.
///
/// Part 2: returns the in-memory [kDummyTutors] list.
/// Part 3: swap this single file for a StreamProvider that listens to the
/// Firestore `tutors` collection — no UI code needs to change.
final tutorsProvider = Provider<List<Tutor>>((ref) => kDummyTutors);
