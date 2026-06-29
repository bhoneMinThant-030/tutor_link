import 'package:flutter/material.dart';

/// Central theme for TutorLINK.
///
/// Uses a red & white palette to match the TP brand that students see daily
/// across the LMS, signage and room themes — chosen in the Part 1 proposal so
/// the app feels familiar and relevant to the target audience.
class AppTheme {
  // Brand colours (single source of truth — reuse these instead of hard-coding).
  static const Color brandRed = Color(0xFFD32F2F);
  static const Color brandWhite = Colors.white;
  static const Color fieldFill = Color(0xFFF6F6F6);
  // Light grey used for the app bar so it stands apart from the white body.
  static const Color headerGrey = Color(0xFFF0F0F0);

  /// The light theme applied across the whole app via [MaterialApp.theme].
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandRed,
      primary: brandRed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brandWhite,

      // Light-grey app bar with a red back chevron and red "TutorLINK" title,
      // left-aligned next to the back button. The grey differentiates the
      // header from the white screen body (matches the design).
      appBarTheme: const AppBarTheme(
        backgroundColor: headerGrey,
        foregroundColor: brandRed,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: headerGrey,
        centerTitle: false,
        iconTheme: IconThemeData(color: brandRed),
        titleTextStyle: TextStyle(
          color: brandRed,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Rounded, full-width red primary buttons used on the forms.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandRed,
          foregroundColor: brandWhite,
          minimumSize: const Size(double.infinity, 48),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Consistent look for every TextFormField in the app.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      // Bottom navigation styling (red selected, grey unselected).
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: brandWhite,
        selectedItemColor: brandRed,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
