import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'loading_overlay.dart';
import 'default_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase connected successfully!");
  } catch (e) {
    print("❌ Firebase connection failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PondStat Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1A73E8),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
            ),
      ),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _showLoginPage = true;
  bool _isLoading = false;

  /// Toggle between login and signup pages with a short overlay animation
  void toggleScreens() async {
    setState(() => _isLoading = true);
    // Small delay to show overlay while switching
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _showLoginPage = !_showLoginPage;
      _isLoading = false;
    });
  }

  // ---------------- SIGN IN ----------------
  Future<void> _signIn(String studentNumber, String password) async {
    setState(() => _isLoading = true); // Show overlay during sign in
    final email = "$studentNumber@pondstat.edu";

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅ Login successful!");

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.displayName != null) {
        // Show a toast-like overlay using ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, ${user.displayName}!')),
        );
      }

      // Navigate to the main dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DefaultDashboardScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Login failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      setState(() => _isLoading = false); // Hide overlay
    }
  }

  // ---------------- SIGN UP ----------------
  Future<void> _signUp(
      String fullName, String studentNumber, String password) async {
    setState(() => _isLoading = true); // Show overlay during signup
    final email = "$studentNumber@pondstat.edu";

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      // Update Auth display name
      await userCredential.user?.updateDisplayName(fullName);

      // Add user document to Firestore
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fullName': fullName,
          'studentNumber': studentNumber,
          'role': 'member',       // Default role
          'assignedPonds': null,  // No assigned ponds yet
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print("✅ Sign-up successful!");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // Automatically switch back to login page
      setState(() => _showLoginPage = true);
    } on FirebaseAuthException catch (e) {
      print("❌ Sign-up failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Sign-up failed")),
      );
    } finally {
      setState(() => _isLoading = false); // Hide overlay
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Show login or signup page
          _showLoginPage
              ? LoginPage(
                  onToggle: toggleScreens,
                  onSignIn: _signIn,
                )
              : SignUpPage(
                  onToggle: toggleScreens,
                  onSignUp: _signUp,
                ),

          // Show overlay when loading
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}