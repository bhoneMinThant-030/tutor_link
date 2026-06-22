import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// NETS QR payment screen (UI mock for Part 2).
///
/// Shows the booking summary and a placeholder QR. "Confirm payment" returns to
/// the app with a success message; Part 3 adds the real NETS flow and saves the
/// booking to Firestore.
class PaymentScreen extends StatelessWidget {
  final String tutorName;
  final String subject;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.tutorName,
    required this.subject,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TutorLINK')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Booking summary card.
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BOOKING SUMMARY',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Session with $tutorName',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        'S\$${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.brandRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // QR placeholder (swap in the real NETS QR asset later).
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEEEEEE)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 160),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan to pay',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan the NETS QR code to complete payment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment confirmed! (demo)')),
              );
              // Return to the first screen (the main tabs).
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Confirm payment'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
