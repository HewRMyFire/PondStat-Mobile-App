import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'no_pond_assigned.dart';
import 'profile_bottom_sheet.dart';
import 'getting_started_dialog.dart';
import 'leader_dashboard.dart';
import 'data_monitoring.dart';

class DefaultDashboardScreen extends StatefulWidget {
  const DefaultDashboardScreen({super.key});

  @override
  State<DefaultDashboardScreen> createState() => _DefaultDashboardScreenState();
}

class _DefaultDashboardScreenState extends State<DefaultDashboardScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isFirstTimeUser = true;

  @override
  void initState() {
    super.initState();
    if (_isFirstTimeUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // _showGettingStartedDialog(context); // Uncomment if needed
        _isFirstTimeUser = false;
      });
    }
    // Removed _ensureUserDocumentExists() call
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

  void _showProfileSheet(BuildContext context, Map<String, dynamic>? userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ProfileBottomSheet(
          isTeamLeader: userData?['role'] == 'leader',
          assignedPond: userData?['assignedPond'],
          onRoleChanged: (isLeader) {
            // UI updates automatically via StreamBuilder
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Something went wrong")));
        }
        
        // Show loading while waiting for initial data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If document doesn't exist, sign out and redirect to login
        if (!snapshot.hasData || !snapshot.data!.exists) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await FirebaseAuth.instance.signOut();
          });

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String role = userData['role'] ?? 'member';
        final String? assignedPond = userData['assignedPond'];
        final String fullName = userData['fullName'] ?? 'User';

        Widget bodyWidget;
        String appBarTitle = 'Dashboard';

        // --- LOGIC TO SWITCH PAGES BASED ON ROLE/POND ---
        if (role == 'leader') {
          if (assignedPond == null || assignedPond.isEmpty) {
            bodyWidget = const LeaderDashboard(); 
            appBarTitle = 'Select Pond';
          } else {
            bodyWidget = MonitoringPage(
              pondLetter: assignedPond,
              leaderName: fullName,
              isLeader: true,
            );
            appBarTitle = '$assignedPond (Leader)';
          }
        } else {
          if (assignedPond == null || assignedPond.isEmpty) {
            bodyWidget = const NoPondAssignedWidget();
            appBarTitle = 'PondStat';
          } else {
            bodyWidget = MonitoringPage(
              pondLetter: assignedPond,
              leaderName: "Team Leader", // Ideally fetch leader name
              isLeader: false,
            );
            appBarTitle = assignedPond;
          }
        }

        // If the body is a page that has its own Scaffold, return it directly
        if (bodyWidget is MonitoringPage || bodyWidget is LeaderDashboard) {
          return bodyWidget;
        }

        // Otherwise, wrap in your standard Dashboard Scaffold
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            title: Row(
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PondStat',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      appBarTitle,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                onPressed: () => _showProfileSheet(context, userData),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: bodyWidget,
        );
      },
    );
  }
}