import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';

/// Profile tab: user header and account actions.
///
/// Shows the signed-in user's name/email (from Firebase). "Log out" is wired to
/// Firebase sign-out; the other tiles are UI-only in Part 2 (Change password /
/// Notification setting arrive in later phases).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    // Capture before the await so we don't use context across an async gap.
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(firebaseServiceProvider).logOut();
      // The auth gate rebuilds to the login screen automatically.
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message ?? e.code)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).asData?.value;
    final name = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName!
        : 'Student';
    final email = user?.email ?? '';

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
              Text(email, style: TextStyle(color: Colors.grey[600])),
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
        const SizedBox(height: 20),
        _tile(context, Icons.person_outline, 'Edit profile'),
        const SizedBox(height: 20),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label (coming soon)')),
              );
            },
      ),
    );
  }
}
