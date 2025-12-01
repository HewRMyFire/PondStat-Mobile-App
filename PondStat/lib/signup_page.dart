import 'package:flutter/material.dart';
import 'auth_header.dart';

class SignUpPage extends StatefulWidget {
  final Function(String, String, String) onSignUp;
  final VoidCallback onToggle;

  const SignUpPage({
    super.key,
    required this.onSignUp,
    required this.onToggle,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _fullNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const AuthHeader(
            title: 'PondStat',
            subtitle: 'Student Sign Up',
          ),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Full Name',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 20.0),
                const Text('Student Number',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _studentNumberController,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 202409454',
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 20.0),
                const Text('Password',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Create a strong password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final fullName = _fullNameController.text.trim();
                      final studentNumber =
                          _studentNumberController.text.trim();
                      final password = _passwordController.text.trim();
                      widget.onSignUp(fullName, studentNumber, password);
                    },
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 40.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 4.0),
                    GestureDetector(
                      onTap: widget.onToggle,
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