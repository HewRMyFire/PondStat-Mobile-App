import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'no_pond_assigned.dart';
import 'profile_bottom_sheet.dart';
import 'getting_started_dialog.dart';
import 'leader_dashboard.dart';
import 'data_monitoring.dart';
import 'team_mgmt.dart'; // Added for direct access if needed

class DefaultDashboardScreen extends StatefulWidget {
  const DefaultDashboardScreen({super.key});

  @override
  State<DefaultDashboardScreen> createState() => _DefaultDashboardScreenState();
}

class _DefaultDashboardScreenState extends State<DefaultDashboardScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool _isFirstTimeUser = true; // In a real app, check SharedPreferences

  @override
  void initState() {
    super.initState();
    if (_isFirstTimeUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only show if we haven't seen it (mock logic for now)
        // _showGettingStartedDialog(context);
        _isFirstTimeUser = false; 
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
            // Role update is handled inside ProfileBottomSheet via Firestore
            // The StreamBuilder below will auto-refresh the UI
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

    // Listen to the current user's document for role/pond changes
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("User data not found.")));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final String role = userData['role'] ?? 'member';
        final String? assignedPond = userData['assignedPond'];
        final String fullName = userData['fullName'] ?? 'User';

        Widget bodyWidget;
        String appBarTitle = 'Dashboard';

        // --- ROUTING LOGIC ---
        if (role == 'leader') {
          if (assignedPond == null || assignedPond.isEmpty) {
            // Leader needs to select a pond
            bodyWidget = const LeaderDashboard(); 
            appBarTitle = 'Select Pond';
          } else {
            // Leader has a pond -> Show Monitoring (with Admin features)
            // Or we could show TeamMgmt as the "Home" for leaders?
            // For now, let's show Monitoring, but add a button to go to Team Mgmt
            bodyWidget = MonitoringPage(
              pondLetter: assignedPond,
              leaderName: fullName, // Self is leader
              isLeader: true,
            );
            appBarTitle = '$assignedPond (Leader)';
          }
        } else {
          // Member
          if (assignedPond == null || assignedPond.isEmpty) {
            bodyWidget = const NoPondAssignedWidget();
            appBarTitle = 'PondStat';
          } else {
            // Member has pond -> Show Monitoring (Read/Write)
            bodyWidget = MonitoringPage(
              pondLetter: assignedPond,
              leaderName: "Team Leader", // We could fetch leader name if needed
              isLeader: false,
            );
            appBarTitle = assignedPond;
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          // Only show the shared AppBar if the child widget isn't providing its own
          // (MonitoringPage and LeaderDashboard usually have their own, but let's standardize)
          // For simplicity here, we'll wrap the body. 
          // Note: MonitoringPage has its own Scaffold/AppBar, so we might return it directly.
          
          body: (bodyWidget is MonitoringPage || bodyWidget is LeaderDashboard) 
              ? bodyWidget // These pages have their own scaffolds
              : Scaffold(
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
                ),
        );
      },
    );
  }
}