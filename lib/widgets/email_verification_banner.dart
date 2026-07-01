import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';

/// Shows the current user's email-verification status on the Profile screen.
///
/// - Verified  -> a small green "Email verified" line.
/// - Not yet   -> an amber banner with "Resend email" and "I've verified"
///   (which reloads the user so the status refreshes without a full re-login).
class EmailVerificationBanner extends ConsumerStatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  ConsumerState<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState
    extends ConsumerState<EmailVerificationBanner> {
  bool _busy = false;

  Future<void> _resend() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(firebaseServiceProvider).sendEmailVerification();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Verification email sent — check your inbox (and spam).'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(firebaseServiceProvider);
    setState(() => _busy = true);
    await service.reloadUser();
    if (!mounted) return;
    setState(() => _busy = false); // rebuild re-reads emailVerified
    final verified = service.getCurrentUser()?.emailVerified ?? false;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? 'Email verified — thank you!'
              : 'Not verified yet. Please open the link in your email.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userChangesProvider).asData?.value;
    final verified = user?.emailVerified ?? false;

    // When verified, the green check beside the email in the header says it
    // all — so this banner shows nothing.
    if (verified) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD08A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Colors.orange[800],
              ),
              const SizedBox(width: 6),
              Text(
                'Email not verified',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify your email to secure your account.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton(
                onPressed: _busy ? null : _resend,
                child: const Text('Resend email'),
              ),
              TextButton(
                onPressed: _busy ? null : _refresh,
                child: const Text("I've verified"),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
