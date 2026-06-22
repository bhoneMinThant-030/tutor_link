import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/booking.dart';
import '../theme/app_theme.dart';
import '../widgets/booking_card.dart';

/// Bookings tab: Upcoming / Past sub-tabs (DefaultTabController) listing the
/// student's bookings. Cancel/Edit give feedback only in Part 2; Part 3 connects
/// them to Firestore. Body-only (MainScaffold provides the Scaffold).
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upcoming = kDummyBookings.where((b) => b.isUpcoming).toList();
    final past = kDummyBookings.where((b) => !b.isUpcoming).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My bookings',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your learning journey and upcoming sessions.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          TabBar(
            labelColor: AppTheme.brandRed,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.brandRed,
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _BookingList(bookings: upcoming),
                _BookingList(bookings: past),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A scrollable list of bookings, or an empty-state message.
class _BookingList extends StatelessWidget {
  final List<Booking> bookings;

  const _BookingList({required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings here yet.'));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: bookings
          .map(
            (b) => BookingCard(
              booking: b,
              onCancel: () => _feedback(context, 'Booking cancelled (demo)'),
              onEdit: () => _feedback(context, 'Coming soon'),
            ),
          )
          .toList(),
    );
  }

  void _feedback(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
