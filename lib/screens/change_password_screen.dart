import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firebase_provider.dart';
import '../widgets/auth_header.dart'; // reuses AuthLabel for consistent labels

/// In-app screen (pushed from the Profile "Change password" tile) that lets a
/// signed-in user change their password. Re-authenticates with the current
/// password, then updates to the new one.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  String? _current;
  String? _newPassword;
  String? _confirm;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    if (_newPassword != _confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref
          .read(firebaseServiceProvider)
          .changePassword(_current!, _newPassword!);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      // Wrong current password surfaces as 'invalid-credential' (or
      // 'wrong-password' on older SDKs) — show a clear message for it.
      final message =
          (e.code == 'invalid-credential' || e.code == 'wrong-password')
          ? 'Current password is incorrect.'
          : (e.message ?? e.code);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// A password field with a show/hide eye toggle.
  Widget _passwordField({
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthLabel(label),
        TextFormField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            ),
          ),
          onSaved: onSaved,
          validator: validator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _passwordField(
                  label: 'CURRENT PASSWORD',
                  obscure: _obscureCurrent,
                  onToggle: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                  onSaved: (v) => _current = v,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Enter your current password'
                      : null,
                ),
                _passwordField(
                  label: 'NEW PASSWORD',
                  obscure: _obscureNew,
                  onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  onSaved: (v) => _newPassword = v,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                _passwordField(
                  label: 'CONFIRM NEW PASSWORD',
                  obscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  onSaved: (v) => _confirm = v,
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Please confirm your new password'
                      : null,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('UPDATE PASSWORD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
