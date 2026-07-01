import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_header.dart';

/// Phone / OTP sign-in. Two steps in one screen:
/// 1) enter a phone number  -> Firebase sends an SMS code;
/// 2) enter the 6-digit code -> sign in.
/// On success the auth gate switches to the app automatically.
class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  String? _verificationId; // set once the SMS code is sent
  bool _codeSent = false;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  /// The phone number exactly as typed (spaces removed). Enter the full number
  /// including the country code, e.g. +6591234567.
  String get _fullNumber => _phoneController.text.trim().replaceAll(' ', '');

  Future<void> _sendCode() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number.')),
      );
      return;
    }
    setState(() => _loading = true);
    await ref
        .read(firebaseServiceProvider)
        .verifyPhoneNumber(
          phoneNumber: _fullNumber,
          onCodeSent: (verificationId) {
            if (!mounted) return;
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _loading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code sent. Enter it below.')),
            );
          },
          onFailed: (e) {
            if (!mounted) return;
            setState(() => _loading = false);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
          },
        );
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.trim().isEmpty || _verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .signInWithSmsCode(_verificationId!, _codeController.text.trim());
      // Signed in. This screen was pushed on top of the login screen, so pop
      // back to the root to reveal the app shell the auth gate now shows.
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'invalid-verification-code'
          ? 'Incorrect code. Please try again.'
          : (e.message ?? e.code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
                    const AuthLabel('PHONE NUMBER'),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: '+6591234567',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loading ? null : _sendCode,
                      child: _loading ? _spinner() : const Text('SEND CODE'),
                    ),
                  ] else ...[
                    AuthLabel('CODE SENT TO $_fullNumber'),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '123456'),
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
    );
  }
}
