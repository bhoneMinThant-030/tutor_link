import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../theme/app_theme.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_header.dart';
import '../widgets/field_label.dart';

/// Phone / OTP sign-in. Two steps in one screen:
/// 1) enter a phone number  -> Firebase sends an SMS code;
/// 2) enter the 6-digit code -> sign in.
///
/// Both steps share one Form: validate() only runs the validators of the
/// fields currently on screen, so each step validates just its own field.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _form = GlobalKey<FormState>();

  // Values captured via onSaved when form.save() runs.
  String? _phone;
  String? _smsCode;

  String? _verificationId; // set once the SMS code is sent
  bool _codeSent = false;
  bool _loading = false;

  Future<void> _sendCode() async {
    // Step 1 validates + saves the phone field. On "Resend code" (step 2) the
    // phone field is no longer on screen, so reuse the saved _phone instead.
    if (!_codeSent) {
      if (!_form.currentState!.validate()) return;
      _form.currentState!.save();
    }

    setState(() => _loading = true);
    await ref
        .read(firebaseServiceProvider)
        .verifyPhoneNumber(
          phoneNumber: _phone!,
          onCodeSent: (verificationId) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _loading = false;
            });
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(content: Text('Code sent. Enter it below.')),
              );
          },
          onFailed: (e) {
            if (!mounted) return;
            setState(() => _loading = false);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(friendlyAuthMessage(e))),
              );
          },
        );
  }

  Future<void> _verifyCode() async {
    // Only the code field is on screen in step 2, so this validates just it.
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    if (_verificationId == null) return;

    setState(() => _loading = true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .signInWithSmsCode(_verificationId!, _smsCode!);
      // Signed in. This screen was pushed on top of the login screen, so pop
      // back to the root to reveal the app shell the auth gate now shows.
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Logged in successfully!')),
        );
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

  Widget _spinner() => const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Sign-In')),
      backgroundColor: AppTheme.headerGrey,
      // SafeArea keeps the card clear of the notch and status bar.
      // SingleChildScrollView stops it overflowing once the keyboard opens.
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
                    Text(
                      _codeSent ? 'ENTER CODE' : 'SIGN IN WITH PHONE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (!_codeSent) ...[
                      const FieldLabel('PHONE NUMBER'),
                      // Distinct key so this counts as a different field from
                      // the code field below, instead of Flutter reusing its
                      // state (and whatever was still typed in it).
                      TextFormField(
                        key: const ValueKey('phone_field'),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '+6591234567',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please provide your phone number.';
                          } else if (!v.trim().startsWith('+')) {
                            return 'Include the country code, e.g. +6591234567.';
                          }
                          return null;
                        },
                        onSaved: (v) => _phone = v?.trim().replaceAll(' ', ''),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _sendCode,
                        child: _loading ? _spinner() : const Text('SEND CODE'),
                      ),
                    ] else ...[
                      FieldLabel('CODE SENT TO $_phone'),
                      // Same reasoning as the phone field's key above.
                      TextFormField(
                        key: const ValueKey('code_field'),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: '123456'),
                        validator: (v) => (v == null || v.trim().length != 6)
                            ? 'Please enter the 6-digit code.'
                            : null,
                        onSaved: (v) => _smsCode = v?.trim(),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _verifyCode,
                        child: _loading ? _spinner() : const Text('VERIFY'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loading ? null : _sendCode,
                        child: const Text('Resend code'),
                      ),
                    ],
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
