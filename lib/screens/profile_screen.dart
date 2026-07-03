import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../theme/app_theme.dart';
import '../utils/auth_error_message.dart';
import '../widgets/email_verification_banner.dart';
import 'change_password_screen.dart';

/// Profile tab: user header and account actions.
///
/// Shows the signed-in user's header (name, email or phone number, verified
/// check) and account actions. "Change password" and "Log out" are wired to
/// Firebase; the remaining tiles are placeholders until Part 3.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Capture before the await so we don't use context across an async gap.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(firebaseServiceProvider).logOut();
      // The auth gate swaps to the login screen; confirm on the way out.
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Logged out successfully!')),
        );
    } on FirebaseAuthException catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(friendlyAuthMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userChanges() (not authStateChanges) so the verified check refreshes
    // after the user reloads following email verification.
    final user = ref.watch(userChangesProvider).asData?.value;
    final name = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : 'Student';
    // Phone accounts have no email — show the phone number instead.
    final email = user?.email ?? user?.phoneNumber ?? '';
    final verified = user?.emailVerified ?? false;
    // Only email/password accounts can change a password.
    final isPasswordUser =
        user?.providerData.any((p) => p.providerId == 'password') ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        // Avatar + name + email header.
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 44,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 13,
                      backgroundColor: AppTheme.brandRed,
                      child: const Icon(
                        Icons.edit,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(email, style: TextStyle(color: Colors.grey[600])),
                  if (verified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: Colors.green),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              // Course + year of study. Hardcoded placeholders in Part 2; in
              // Part 3 these are captured at sign-up and feed the tutor
              // recommendation engine on the home page.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 16,
                    color: AppTheme.brandRed,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Computer Engineering · Year 1',
                    style: TextStyle(
                      color: AppTheme.brandRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const EmailVerificationBanner(),
        const SizedBox(height: 20),
        _tile(context, Icons.person_outline, 'Edit profile'),
        const SizedBox(height: 20),
        if (isPasswordUser) ...[
          _tile(
            context,
            Icons.lock_reset,
            'Change password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const SizedBox(height: 20),
        ],
        _tile(context, Icons.notifications_outlined, 'Notification setting'),
        const SizedBox(height: 20),
        _tile(
          context,
          Icons.logout,
          'Log out',
          isLogout: true,
          onTap: () => _logout(context, ref),
        ),
      ],
    );
  }

  /// A single settings row. [isLogout] styles it red. If [onTap] is given it
  /// runs that action; otherwise it shows a "coming soon" message.
  Widget _tile(
    BuildContext context,
    IconData icon,
    String label, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    final color = isLogout ? AppTheme.brandRed : Colors.black87;
    return Card(
      elevation: 0,
      color: isLogout ? const Color(0xFFFDECEC) : const Color(0xFFF7F7F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: Icon(
          isLogout ? Icons.arrow_forward : Icons.chevron_right,
          color: color,
        ),
        onTap:
            onTap ??
            () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('$label (coming soon)')),
                );
            },
      ),
    );
  }
}
