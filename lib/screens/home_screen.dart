import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutor.dart';
import '../providers/firebase_provider.dart';
import '../providers/tutors_provider.dart';
import '../widgets/tutor_card.dart';
import 'booking_form_screen.dart';
import 'tutor_profile_screen.dart';

/// Home tab: greeting, a working search box + filters, a "Recommended for you"
/// section and the full tutor list. Body-only (MainScaffold provides Scaffold).
///
/// When no search text or filter is active it shows Recommended (the first 3
/// tutors a placeholder for the Part 3 content-based scoring) followed by all
/// other tutors. When the user searches or filters, it shows a single results
/// list instead.
///
/// Extends [ConsumerStatefulWidget] so it can read [tutorsProvider] via
/// Riverpod AND hold local search/filter state.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();

  /// Slider upper bound, treated as "any price" (no price filter).
  static const double _priceCap = 30;
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // Current search + filter state (null / empty / defaults mean "no filter").
  String _query = '';
  String? _subject;
  final Set<String> _selectedDays = {}; // multi-select: match ANY selected day
  double _maxPrice = _priceCap;
  double _minRating = 0;

  /// True when any search text or filter narrows the list.
  bool get _isFiltering =>
      _query.trim().isNotEmpty ||
      _subject != null ||
      _selectedDays.isNotEmpty ||
      _maxPrice < _priceCap ||
      _minRating > 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Whether a tutor passes the current search text and every active filter.
  bool _matches(Tutor t) {
    final q = _query.trim().toLowerCase();
    final matchesQuery =
        q.isEmpty ||
        t.name.toLowerCase().contains(q) ||
        t.subjects.any((s) => s.toLowerCase().contains(q));
    final matchesSubject = _subject == null || t.subjects.contains(_subject);
    // Multi-select: pass if the tutor is free on ANY of the selected days.
    final matchesDay =
        _selectedDays.isEmpty ||
        _selectedDays.any((d) => t.availableDays.contains(d));
    final matchesPrice = t.hourlyRate <= _maxPrice;
    final matchesRating = t.rating >= _minRating;
    return matchesQuery &&
        matchesSubject &&
        matchesDay &&
        matchesPrice &&
        matchesRating;
  }

  void _openProfile(Tutor tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TutorProfileScreen(tutor: tutor)),
    );
  }

  void _book(Tutor tutor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingFormScreen(tutor: tutor)),
    );
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _searchController.clear();
      _subject = null;
      _selectedDays.clear();
      _maxPrice = _priceCap;
      _minRating = 0;
    });
  }

  /// Bottom sheet with subject / day / price / rating filters. Works on
  /// temporary copies so "Apply" commits and dismissing cancels.
  Future<void> _openFilterSheet(List<Tutor> tutors) async {
    // All distinct subjects across the tutors, sorted.
    final subjects = <String>{for (final t in tutors) ...t.subjects}.toList()
      ..sort();

    // Temporary copies of the committed state.
    String? tempSubject = _subject;
    final Set<String> tempDays = {..._selectedDays};
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;

    // Controller for the searchable subject dropdown (disposed after close).
    final subjectMenuController = TextEditingController(text: tempSubject ?? '');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheet) {
            return Padding(
              // Lift above the keyboard when the subject search is focused.
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Subject',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  // Searchable dropdown: type to filter, scrolls to any length.
                  DropdownMenu<String?>(
                    controller: subjectMenuController,
                    expandedInsets: EdgeInsets.zero, // fill the sheet width
                    enableFilter: true,
                    requestFocusOnTap: true,
                    menuHeight: 260,
                    hintText: 'Any subject',
                    onSelected: (value) => setSheet(() => tempSubject = value),
                    dropdownMenuEntries: subjects
                        .map(
                          (s) =>
                              DropdownMenuEntry<String?>(value: s, label: s),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Available day (any selected)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: _days.map((d) {
                      return FilterChip(
                        label: Text(d),
                        selected: tempDays.contains(d),
                        onSelected: (sel) => setSheet(() {
                          if (sel) {
                            tempDays.add(d);
                          } else {
                            tempDays.remove(d);
                          }
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Max price: \$${tempMaxPrice.round()}/hr',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    min: 10,
                    max: _priceCap,
                    divisions: 20,
                    label: '\$${tempMaxPrice.round()}',
                    value: tempMaxPrice,
                    onChanged: (v) => setSheet(() => tempMaxPrice = v),
                  ),

                  Text(
                    'Min rating: ${tempMinRating.toStringAsFixed(1)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Slider(
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: tempMinRating.toStringAsFixed(1),
                    value: tempMinRating,
                    onChanged: (v) => setSheet(() => tempMinRating = v),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setSheet(() {
                            tempSubject = null;
                            tempDays.clear();
                            tempMaxPrice = _priceCap;
                            tempMinRating = 0;
                            subjectMenuController.clear();
                          }),
                          child: const Text('Clear'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _subject = tempSubject;
                              _selectedDays
                                ..clear()
                                ..addAll(tempDays);
                              _maxPrice = tempMaxPrice;
                              _minRating = tempMinRating;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // The sheet is closed. Release its local controller.
    subjectMenuController.dispose();
  }

  /// Builds a TutorCard wired to the profile / booking actions.
  Widget _card(Tutor t) => TutorCard(
    tutor: t,
    onTap: () => _openProfile(t),
    onBook: () => _book(t),
  );

  @override
  Widget build(BuildContext context) {
    final tutors = ref.watch(tutorsProvider);
    final filtered = tutors.where(_matches).toList();

    // Greet the signed-in user by their first name (from Firebase).
    final user = ref.watch(authStateProvider).asData?.value;
    final greetingName = user?.displayName?.split(' ').first ?? 'there';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Hello, $greetingName.',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Ready to get your tutoring session?',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // Search box + filter button.
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name or subject',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => _openFilterSheet(tutors),
              icon: const Icon(Icons.tune),
              tooltip: 'Filters',
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Either the filtered results, or the Recommended + All sections.
        if (_isFiltering) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Results (${filtered.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(onPressed: _clearFilters, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 4),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('No tutors match your search.')),
            )
          else
            ...filtered.map(_card),
        ] else ...[
          const Text(
            'RECOMMENDED FOR YOU',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          // Part 3: replace `.take(3)` with the content-based scored top 3.
          ...tutors.take(3).map(_card),
          const SizedBox(height: 16),
          const Text(
            'ALL TUTORS',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          ...tutors.skip(3).map(_card),
        ],
      ],
    );
  }
}
