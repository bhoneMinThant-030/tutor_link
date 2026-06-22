// Basic smoke test for TutorLINK.
//
// Verifies that the app builds and the bottom-navigation shell renders with its
// three tabs. More detailed tests can be added as screens are implemented.

import 'package:flutter_test/flutter_test.dart';

import 'package:tutor_link/main.dart';

void main() {
  testWidgets('App launches and shows the bottom navigation tabs', (
    WidgetTester tester,
  ) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TutorLinkApp());

    // The three bottom-navigation tabs should be present.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
