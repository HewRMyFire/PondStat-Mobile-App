import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_header.dart';

class LoginPage extends StatefulWidget {
  final Function(String, String) onSignIn;
  final VoidCallback onToggle;

  const LoginPage({
    super.key,
    required this.onSignIn,
    required this.onToggle,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _forgotPassword() async {
    final studentNumber = _studentNumberController.text.trim();
    if (studentNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your student number first.')),
      );
      return;
    }

    final email = "$studentNumber@pondstat.edu";

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent! Check your inbox.')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to send reset email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AuthHeader(
            title: 'PondStat',
            subtitle: 'Student Login',
          ),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Student Number',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _studentNumberController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 202409454',
                  ),
                ),
                const SizedBox(height: 20.0),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Password',
                      style:
                          TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: _forgotPassword,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'Forgot?',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final studentNumber = _studentNumberController.text.trim();
                      final password = _passwordController.text.trim();
                      widget.onSignIn(studentNumber, password);
                    },
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 4.0),
                    GestureDetector(
                      onTap: widget.onToggle,
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}