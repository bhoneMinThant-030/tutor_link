import 'package:flutter/material.dart';

import '../models/tutor.dart';
import '../widgets/field_label.dart';
import '../widgets/rating_label.dart';
import '../widgets/tutor_avatar.dart';
import 'payment_screen.dart';

/// Booking form.
///
/// Demonstrates Form + TextFormField + DropdownButtonFormField with validation
/// (rubric: Widgets + Form validation). Text fields capture their values with
/// the `onSaved` + `form.save()` pattern (same as the class lab).
///
/// In Part 2 a valid submit gives feedback and navigates to the payment screen;
/// Part 3 saves the booking to Firestore (inside the try/catch in [_submit]).
class BookingFormScreen extends StatefulWidget {
  final Tutor tutor;

  const BookingFormScreen({super.key, required this.tutor});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Values captured via onSaved when form.save() runs.
  String? _location;
  String? _notes;

  // Values set directly (dropdown / pickers are not plain text fields).
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Shows the standard Material time picker and stores the chosen time.
  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: (isStart ? _startTime : _endTime) ?? TimeOfDay.now(),
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
    // 1. Run the inline validators (subject dropdown + location field),
    //    exactly like the class lab's expense form.
    final isValid = _formKey.currentState!.validate();

    // 2. The date/time pickers are not FormFields, so they are checked
    //    separately with SnackBar feedback — the same way the lab handles
    //    its date picker outside the Form.
    final missing = <String>[];
    if (_date == null) missing.add('date');
    if (_startTime == null) missing.add('start time');
    if (_endTime == null) missing.add('end time');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Please provide: ${missing.join(', ')}.')),
        );
    }
    if (!isValid || missing.isNotEmpty) return;

    // 3. Capture the text-field values (fires every onSaved).
    _formKey.currentState!.save();

    debugPrint('Subject: $_subject  Date: $_date');
    debugPrint('Start: $_startTime  End: $_endTime');
    debugPrint('Location: $_location  Notes: $_notes');

    // 4. Dismiss the keyboard and confirm success to the user.
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Booking details confirmed — proceeding to payment.'),
        ),
      );

    // 5. Continue to payment.
    //    Part 3: save the booking to Firestore here first, wrapped in a
    //    try/catch with a success / error SnackBar.
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
      // The form scrolls in the body; the price + "Book session" bar is pinned
      // in bottomNavigationBar below, so there is no empty gap under the form.
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
              'Secure your time with a qualified tutor. Fill in the '
              'details below to proceed.',
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

            const FieldLabel('SUBJECT'),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              items: _subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v),
              validator: (v) => v == null ? 'Please select a subject.' : null,
            ),
            const SizedBox(height: 12),

            const FieldLabel('DATE'),
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
                      const FieldLabel('START TIME'),
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
                      const FieldLabel('END TIME'),
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

            const FieldLabel('LOCATION'),
            TextFormField(
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Library, lvl 1, Hub 1',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please provide a location.'
                  : null,
              onSaved: (value) => _location = value?.trim(),
            ),
            const SizedBox(height: 12),

            const FieldLabel('ADDITIONAL NOTES'),
            TextFormField(
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'What would you like to focus on during this session?',
              ),
              onSaved: (value) => _notes = value?.trim(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Pinned price + action bar (kept out of the scroll view).
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
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
