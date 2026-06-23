import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/tutor.dart';
import '../theme/app_theme.dart';
import '../widgets/rating_label.dart';
import '../widgets/tutor_avatar.dart';
import 'payment_screen.dart';

/// Booking form.
///
/// Demonstrates Form + TextFormField + DropdownButtonFormField with validation
/// (rubric: Widgets + Form validation). In Part 2 it navigates to the payment
/// screen; Part 3 saves the booking to Firestore.
class BookingFormScreen extends StatefulWidget {
  final Tutor tutor;

  const BookingFormScreen({super.key, required this.tutor});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String? _subject;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  List<String> get _subjects => widget.tutor.subjects;

  @override
  void initState() {
    super.initState();
    // Pre-select the tutor's first subject.
    _subject = _subjects.isNotEmpty ? _subjects.first : null;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Shows an iOS-style wheel time picker (hour · minute · AM/PM) in a bottom
  /// sheet, themed to match the app, and stores the chosen time.
  Future<void> _pickTime({required bool isStart}) async {
    final now = DateTime.now();
    final existing = isStart ? _startTime : _endTime;

    // CupertinoDatePicker works with DateTime, so seed it from the existing
    // selection (or "now" if nothing is chosen yet). Only the time matters.
    var temp = DateTime(
      now.year,
      now.month,
      now.day,
      existing?.hour ?? now.hour,
      existing?.minute ?? now.minute,
    );

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                // Header: title on the left, red "Done" on the right.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isStart ? 'Start time' : 'End time',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(
                          sheetContext,
                          TimeOfDay(hour: temp.hour, minute: temp.minute),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            color: AppTheme.brandRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // The spinner wheels.
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: temp,
                    use24hFormat: false,
                    onDateTimeChanged: (value) => temp = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    // Validate the text/dropdown fields first.
    if (!_formKey.currentState!.validate()) return;

    // Date and time use custom pickers, so check them separately.
    if (_date == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose a date, start and end time.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          tutorName: widget.tutor.name,
          subject: _subject ?? '',
          amount: widget.tutor.hourlyRate * 2, // 2-hour sample session
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tutor = widget.tutor;
    return Scaffold(
      appBar: AppBar(title: const Text('TutorLINK')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Book a Session',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Secure your time with a qualified tutor. Fill in the details '
              'below to proceed.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Tutor summary card.
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFEEEEEE)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    TutorAvatar(tutor: tutor, size: 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            tutor.course,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '\$${tutor.hourlyRate.toStringAsFixed(0)} /hr',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    RatingLabel(rating: tutor.rating),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _Label('SUBJECT'),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              items: _subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v),
              validator: (v) => v == null ? 'Please choose a subject' : null,
            ),
            const SizedBox(height: 12),

            const _Label('DATE'),
            _PickerField(
              text: _date == null
                  ? 'mm/dd/yyyy'
                  : '${_date!.day}/${_date!.month}/${_date!.year}',
              icon: Icons.calendar_today,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('START TIME'),
                      _PickerField(
                        text: _startTime?.format(context) ?? '--:--',
                        icon: Icons.access_time,
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Label('END TIME'),
                      _PickerField(
                        text: _endTime?.format(context) ?? '--:--',
                        icon: Icons.access_time,
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const _Label('LOCATION'),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                hintText: 'e.g. Library, lvl 1, Hub 1',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a location'
                  : null,
            ),
            const SizedBox(height: 12),

            const _Label('ADDITIONAL NOTES'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'What would you like to focus on during this session?',
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PRICE',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                    Text(
                      '\$${(tutor.hourlyRate * 2).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Book session'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small grey uppercase field label.
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Read-only field that opens a picker (date or time) when tapped.
class _PickerField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerField({
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text),
            Icon(icon, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
