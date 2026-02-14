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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      _isNameValid = value.trim().isNotEmpty;
    });
  }

  void _validateEmail(String value) {
    final trimmed = value.trim();
    final isValid = trimmed.endsWith('@up.edu.ph') && trimmed.length > 10;
    setState(() {
      _isEmailValid = isValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const AuthHeader(
                  title: 'Hello There!',
                  subtitle: 'Join PondStat today',
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      // Full Name Field
                      _buildInputContainer(
                        isValid: _isNameValid,
                        child: TextField(
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          onChanged: _validateName,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: _isNameValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            filled: false,
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _isNameValid ? Colors.blue : Colors.grey,
                                width: _isNameValid ? 2.0 : 1.0,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      // Email Field
                      _buildInputContainer(
                        isValid: _isEmailValid,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: _validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email (@up.edu.ph)',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.grey[600],
                            ),
                            suffixIcon: _isEmailValid
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : null,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            filled: false,
                            border: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _isEmailValid
                                    ? Colors.blue
                                    : Colors.grey,
                                width: _isEmailValid ? 2.0 : 1.0,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20.0),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.grey[600],
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              );
                            },
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed: () {
                            final name = _fullNameController.text.trim();
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();

                            if (!email.endsWith('@up.edu.ph')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please use your @up.edu.ph email.',
                                  ),
                                ),
                              );
                              return;
                            }
                            widget.onSignUp(name, email, password);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16.0),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              "or",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 16.0),

                      // Log In Button
                      SizedBox(
                        width: double.infinity,
                        height: 48.0,
                        child: OutlinedButton(
                          onPressed: widget.onToggle,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            padding: EdgeInsets.zero,
                            side: BorderSide(color: primaryColor, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24.0),
                            ),
                          ),
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black12,
              radius: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputContainer({
    required bool isValid,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isValid
                ? Colors.blue.withOpacity(0.15)
                : Colors.transparent,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}