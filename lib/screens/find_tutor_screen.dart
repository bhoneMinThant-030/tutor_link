import 'package:flutter/material.dart';

import 'search_results_screen.dart';

/// AI Search tab: the student describes what they need in natural language and
/// taps "Find Matches".
///
/// For Part 2 this just navigates to a results screen with sample matches — the
/// real LLM call is added in Part 3.
class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  final _controller = TextEditingController();

  // Quick-fill suggestions shown as chips under the text box.
  static const _popular = [
    'Math help',
    'Evening availability',
    'Advanced project',
    'coding tips',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPopular(String text) {
    final existing = _controller.text.trim();
    setState(() {
      _controller.text = existing.isEmpty ? text : '$existing, $text';
    });
  }

  void _findMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchResultsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Find My Tutor',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Describe your desired tutor or the subject you're struggling with. "
          'Our AI will match you with the best fit.',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tell us what you need',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText:
                "e.g. I'm looking for a calculus tutor who can help me with "
                'derivatives and integrals. I prefer someone patient who can '
                "explain things with real-world examples. I'm available on "
                'weekends.',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Popular requests',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popular
              .map(
                (p) => ActionChip(
                  label: Text(p),
                  onPressed: () => _addPopular(p),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _findMatches,
          icon: const Icon(Icons.search),
          label: const Text('Find Matches'),
        ),
      ],
    );
  }
}
