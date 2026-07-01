import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Profile tab: user header and account actions.
///
/// The actions are UI-only in Part 2. The authentication phase wires
/// "Change password" and "Log out" to Firebase, and "Notification setting"
/// links to the additional feature in Part 3.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Bhone',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'bmt7505@gmail.com',
                style: TextStyle(color: Colors.grey[600]),
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
                  Text(
                    'Computer Engineering · Year 1',
                    style: const TextStyle(
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
        _tile(context, Icons.lock_reset, 'Change password'),
        const SizedBox(height: 20),
        _tile(context, Icons.notifications_outlined, 'Notification setting'),
        const SizedBox(height: 20),
        _tile(context, Icons.logout, 'Log out', isLogout: true),
      ],
    );
  }

  /// A single settings row. [isLogout] styles it red and is wired to Firebase
  /// sign-out during the authentication phase.
  Widget _tile(
    BuildContext context,
    IconData icon,
    String label, {
    bool isLogout = false,
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label (coming soon)')),
          );
        },
      ),
    );
  }
}
