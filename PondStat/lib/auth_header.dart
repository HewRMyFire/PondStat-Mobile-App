import 'package:flutter/material.dart';

// --- Header Widget ---
// A reusable header widget for both screens
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
        ),
      ),
      child: Column(
        children: [
          // The icon
          const Icon(
            Icons.waves, // Using 'waves' icon as a stand-in
            color: Colors.white,
            size: 60.0,
          ),
          const SizedBox(height: 16.0),
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
