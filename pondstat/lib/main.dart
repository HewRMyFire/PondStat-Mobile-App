import 'package:flutter/material.dart';
import 'dart:async'; // For Future.delayed

// Import the new separated widgets
import 'login_page.dart';
import 'signup_page.dart';
import 'loading_overlay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Use a light theme
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        // Define a custom blue color to match the header
        primaryColor: const Color(0xFF1A73E8),
        // Set scaffold background color to white
        scaffoldBackgroundColor: Colors.white,
        // Style text form fields for light theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200], // Light grey fill
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(color: Colors.grey[600]), // Darker hint text
        ),
        // Style elevated buttons
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A73E8), // Primary blue
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        // Style text buttons (for the secondary grey buttons)
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[300], // Light grey background
            foregroundColor: Colors.black87, // Dark text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
        // Set text color for light theme
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
  // State to manage which page to show
  bool _showLoginPage = true;
  // State to manage the loading overlay
  bool _isLoading = false;

  // Method to toggle between login and sign-up pages
  void toggleScreens() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  // --- Mock Auth Functions ---
  // These simulate network calls and show the loading screen.

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
    
    // Here you would navigate to your home screen on success
    // For this demo, we'll just hide the loader.
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Sign In Successful!')),
    // );
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a network request
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // On successful sign-up, you might want to switch to the login page
    // or log the user in directly.
    // setState(() {
    //   _showLoginPage = true;
    // });
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Sign Up Successful! Please Sign In.')),
    // );
  }
  
  // --- End Mock Auth Functions ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The main content (Login or Sign Up)
          _showLoginPage
              ? LoginPage(
                  onToggle: toggleScreens,
                  onSignIn: _signIn,
                )
              : SignUpPage(
                  onToggle: toggleScreens,
                  onSignUp: _signUp,
                ),

          // The loading overlay
          if (_isLoading)
            const LoadingOverlay(),
        ],
      ),
    );
  }
}

