import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../theme/app_theme.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_header.dart';
import '../widgets/field_label.dart';

/// Email/password registration. Pushed from the login screen. On success
/// Firebase signs the new user in, so the auth gate shows the app. We pop back
/// to the root to reveal it.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  String? _name;
  String? _email;
  String? _password;
  String? _confirmPassword;
  String? _course;
  int? _year;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    // Part 3: course/year get written to the user's Firestore document here so
    // the home recommendation engine can personalise. Captured now for the UI.
    debugPrint('Course: $_course, Year: $_year');

    // Checked by hand because a field validator only ever sees its own
    // value. It has no way to compare against the password field above it.
    if (_password != _confirmPassword) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .register(_email!, _password!, _name!);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Account created! Check your email to verify it.'),
          ),
        );
      // New user is now signed in. Clear this screen so the auth gate's app
      // shell shows through.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(friendlyAuthMessage(e))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.headerGrey,
      // With six fields this is the tallest form in the app, so
      // SingleChildScrollView matters here to avoid overflowing when the
      // keyboard opens. SafeArea keeps clear of the notch and status bar.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AuthHeader(),
                    const SizedBox(height: 16),
                    const Text(
                      'REGISTER',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const FieldLabel('NAME'),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(hintText: 'Bhone'),
                      onSaved: (v) => _name = v?.trim(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 8),

                    const FieldLabel('EMAIL ADDRESS'),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'bmt555@gmail.com',
                      ),
                      onSaved: (v) => _email = v?.trim(),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please provide an email address.';
                        } else if (!v.contains('@')) {
                          return 'Please provide a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    const FieldLabel('COURSE'),
                    TextFormField(
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Computer Engineering',
                      ),
                      onSaved: (v) => _course = v?.trim(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your course'
                          : null,
                    ),
                    const SizedBox(height: 8),

                    const FieldLabel('YEAR OF STUDY'),
                    DropdownButtonFormField<int>(
                      initialValue: _year,
                      isExpanded: true,
                      hint: const Text('Select your year'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Year 1')),
                        DropdownMenuItem(value: 2, child: Text('Year 2')),
                        DropdownMenuItem(value: 3, child: Text('Year 3')),
                      ],
                      onChanged: (v) => setState(() => _year = v),
                      validator: (v) =>
                          v == null ? 'Please select your year' : null,
                    ),
                    const SizedBox(height: 8),

                    const FieldLabel('PASSWORD'),
                    TextFormField(
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onSaved: (v) => _password = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please provide a password.';
                        } else if (v.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    const FieldLabel('CONFIRM PASSWORD'),
                    TextFormField(
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      onSaved: (v) => _confirmPassword = v,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Please confirm your password'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('SIGN UP'),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? '),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Log in',
                            style: TextStyle(
                              color: AppTheme.brandRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
