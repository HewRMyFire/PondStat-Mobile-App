import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'firestore_helper.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _bubbleController;
  late AnimationController _textController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutQuart,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textController.forward();
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoading() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _signIn(String email, String password) async {
    _showLoading();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        _hideLoading();
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _hideLoading();
        String errorMessage = e.message ?? "Login failed";
        if (e.code == 'network-request-failed') {
          errorMessage = "Network error. Check internet connection.";
        } else if (e.code == 'user-not-found') {
          errorMessage = "User not found. Please sign up first.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signUp(String fullName, String email, String password) async {
    _showLoading();
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        await userCredential.user?.updateDisplayName(fullName);

        await FirestoreHelper.usersCollection.doc(uid).set({
          'fullName': fullName,
          'email': email,
          'role': 'member',
          'assignedPond': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) {
        _hideLoading();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please Log In.')),
        );

        _navigateToLogin();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _hideLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? "Sign-up failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      try {
        await userCredential?.user?.delete();
      } catch (_) {}

      if (mounted) {
        _hideLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error creating profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onSignIn: _signIn,
          onToggle: () {
            Navigator.pop(context);
            _navigateToSignUp();
          },
        ),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpPage(
          onSignUp: _signUp,
          onToggle: () {
            Navigator.pop(context);
            _navigateToLogin();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Animated Bubbles
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bubbleController,
              builder: (context, child) {
                final t = _bubbleController.value;
                return Stack(
                  children: [
                    _buildBubble(t, -50, -50, 180, 0),
                    _buildBubble(t, 80, 300, 100, 2),
                    _buildBubble(t, 400, -50, 140, 4),
                    _buildBubble(t, 500, 200, 80, 1.5),
                    _buildBubble(t, 200, 100, 60, 3.5),
                  ],
                );
              },
            ),
          ),

          // Foreground Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo/Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      const Text(
                        'PondStat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Animated Text & Buttons
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Smart Pond Monitoring',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32.0,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 10.0,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            'Real-time analytics for your aquaculture.\nTrack parameters, manage teams, and boost production.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 15.0,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 48.0,
                              child: ElevatedButton(
                                onPressed: _navigateToLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: primaryColor,
                                  elevation: 2,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                child: const Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16.0),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 48.0,
                              child: OutlinedButton(
                                onPressed: _navigateToSignUp,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.zero,
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(
    double t,
    double top,
    double left,
    double size,
    double offset,
  ) {
    final x = 15 * math.cos(t * 2 * math.pi + offset);
    final y = 15 * math.sin(t * 2 * math.pi + offset);
    return Positioned(
      top: top + y,
      left: left + x,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}