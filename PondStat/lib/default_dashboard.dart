import 'package:flutter/material.dart';
// Make sure these paths are correct for your project
import 'no_pond_assigned.dart';
import 'profile_bottom_sheet.dart';
import 'getting_started_dialog.dart';
// 1. IMPORT YOUR EXISTING LEADER DASHBOARD FILE
import 'leader_dashboard.dart'; // Make sure this path is correct

// --- THIS MAKES THE FILE RUNNABLE FOR TESTING ---
void main() {
  runApp(
    MaterialApp(
      title: 'PondStat (Test)',
      theme: ThemeData(
        // 1. UPDATED THEME COLOR to match
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const DefaultDashboardScreen(),
    ),
  );
}
// ------------------------------------

class DefaultDashboardScreen extends StatefulWidget {
  const DefaultDashboardScreen({super.key});

  @override
  State<DefaultDashboardScreen> createState() => _DefaultDashboardScreenState();
}

class _DefaultDashboardScreenState extends State<DefaultDashboardScreen> {
  bool _isTeamLeader = false;
  final bool _isFirstTimeUser = true;

  @override
  void initState() {
    super.initState();
    if (_isFirstTimeUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGettingStartedDialog(context);
      });
    }
  }

  void _showGettingStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GettingStartedDialog();
      },
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ProfileBottomSheet(
          isTeamLeader: _isTeamLeader,
          assignedPond: null,
          onRoleChanged: (isLeader) {
            // Update the state
            setState(() {
              _isTeamLeader = isLeader;
            });

            if (isLeader) {
              // If the user just became a leader...
              // 1. Close the bottom sheet
              Navigator.pop(context);
              // 2. Navigate to your existing SelectPanelPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderDashboard(),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // 2. UPDATED APPBAR STYLES
        backgroundColor: Colors.blue, // Use simple Colors.blue
        foregroundColor: Colors.white,
        title: Row(
          children: [
            // 3. UPDATED ICON
            const Icon(Icons.water_drop, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                // 4. UPDATED FONT STYLES
                Text(
                  'PondStat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text(
                  'Dashboard', // Kept "Dashboard" as it's the default screen
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 5. UPDATED PROFILE ICON STYLE
          IconButton(
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            onPressed: () => _showProfileSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const NoPondAssignedWidget(),
    );
  }
}