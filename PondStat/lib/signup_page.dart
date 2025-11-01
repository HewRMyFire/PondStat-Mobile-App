import 'package:flutter/material.dart';
import 'auth_header.dart';

// --- Sign Up Page ---
class SignUpPage extends StatelessWidget {
  final VoidCallback onToggle;
  final VoidCallback onSignUp;

  const SignUpPage({
    super.key,
    required this.onToggle,
    required this.onSignUp,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          const AuthHeader(
            title: 'PondStat',
            subtitle: 'Student Sign Up',
          ),
          const SizedBox(height: 40.0),

          // Form
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Name
                const Text(
                  'Full Name',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                
                // Student Number
                const Text(
                  'Student Number',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'e.g., 2024-09454',
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20.0),

                // Password
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Create a strong password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onSignUp,
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 40.0),

                // Toggle to Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4.0),
                    GestureDetector(
                      onTap: onToggle,
                      child: Text(
                        'Sign In',
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
