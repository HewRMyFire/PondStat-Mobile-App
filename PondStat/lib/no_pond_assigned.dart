import 'package:flutter/material.dart';

// --- THIS MAKES THE FILE RUNNABLE FOR TESTING ---
void main() {
  runApp(
    MaterialApp(
      title: 'PondStat (Test)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A7ABF)),
        scaffoldBackgroundColor: Colors.white, // Changed background to white
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // This is the "top part" for testing
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A7ABF),
          foregroundColor: Colors.white,
          title: Row(
            children: [
              const Icon(Icons.waves),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PondStat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Dashboard', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.person_outline, size: 30),
            ),
          ],
        ),
        body: const NoPondAssignedWidget(),
      ),
    ),
  );
}
// ------------------------------------

class NoPondAssignedWidget extends StatelessWidget {
  const NoPondAssignedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      width: double.infinity,
      color: Colors.white, // Ensure background is white
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40), // Add some space from the AppBar
          
          // Icon with circular background
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE3F2FD), // Light blue background
            child: Icon(
              Icons.waves,
              color: Theme.of(context).colorScheme.primary,
              size: 45,
            ),
          ),
          const SizedBox(height: 24),

          // "No Pond Assigned" text is red
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'No Pond Assigned',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Underlined, blue helper text (not in a box)
          const Text(
            "You haven't been assigned a pond yet. Please contact your team leader to get access to pond monitoring.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0A7ABF),
              fontSize: 14,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF0A7ABF),
              decorationThickness: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // "Keep track of" box with reddish theme
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50], // Light red background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[100]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Once assigned, you\'ll be able to keep track of:',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildRecordItem('Daily records')),
                    Expanded(child: _buildRecordItem('Biweekly records')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildRecordItem('Weekly records')),
                    Expanded(child: _buildRecordItem('Feeding records')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Colors.blue, // Using blue bullets as in the mockup
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
      ],
    );
  }
}