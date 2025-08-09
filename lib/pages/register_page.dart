// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _email.text.trim();
    final pass = _password.text;
    final conf = _confirm.text;

    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (pass != conf) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null) Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading ? const CircularProgressIndicator() : const Text('Create account'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Already have an account? Log in"),
            ),
          ],
        ),
      ),
    );
  }
}
