import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'loading_overlay.dart';
import 'default_dashboard.dart';
import 'firestore_helper.dart'; // Import Helper

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Enable offline persistence to help with spotty connections
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
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
      title: 'PondStat',
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingOverlay();
        }
        if (snapshot.hasData) {
          return const DefaultDashboardScreen();
        }
        return const AuthPage();
      },
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

  void toggleScreens() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      _showLoginPage = !_showLoginPage;
      _isLoading = false;
    });
  }

  Future<void> _signIn(String studentNumber, String password) async {
    setState(() => _isLoading = true);
    final email = "$studentNumber@pondstat.edu";

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅ Login successful!");
    } on FirebaseAuthException catch (e) {
      print("❌ Login failed: ${e.code} - ${e.message}");
      
      String errorMessage = e.message ?? "Login failed";
      
      if (e.code == 'network-request-failed') {
        errorMessage = "Network error. Check internet or add SHA-1 in Firebase Console.";
      } else if (e.code == 'user-not-found') {
        errorMessage = "User not found. Please sign up first.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp(
      String fullName, String studentNumber, String password) async {
    setState(() => _isLoading = true);
    final email = "$studentNumber@pondstat.edu";
    
    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        await userCredential.user?.updateDisplayName(fullName);
        
        // Use FirestoreHelper for consistent paths
        await FirestoreHelper.usersCollection.doc(uid).set({
          'fullName': fullName,
          'studentNumber': studentNumber,
          'role': 'member',
          'assignedPond': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print("✅ Sign-up successful!");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
         setState(() => _showLoginPage = true);
      }
    } on FirebaseAuthException catch (e) {
      print("❌ Sign-up failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Sign-up failed")),
        );
      }
    } catch (e) {
      print("❌ Firestore creation failed. Rolling back user.");
      try {
        await userCredential?.user?.delete();
      } catch (delError) {
        print("Failed to delete user during rollback: $delError");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _showLoginPage
              ? LoginPage(
                  onToggle: toggleScreens,
                  onSignIn: _signIn,
                )
              : SignUpPage(
                  onToggle: toggleScreens,
                  onSignUp: _signUp,
                ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}