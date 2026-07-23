import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutor.dart';

/// Streams the list of tutors from the Firestore `tutors` collection.
///
/// Only active tutors are shown. Emits a new list automatically whenever a
/// tutor document changes, so the UI stays in sync without a manual refresh.
final tutorsProvider = StreamProvider<List<Tutor>>((ref) {
  return FirebaseFirestore.instance
      .collection('tutors')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Tutor.fromFirestore(doc)).toList(),
      );
});
