import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'no_pond_assigned.dart';
import 'profile_bottom_sheet.dart';
import 'getting_started_dialog.dart';
import 'leader_dashboard.dart';
import 'data_monitoring.dart'; 
import 'loading_overlay.dart';

class DefaultDashboardScreen extends StatefulWidget {
  const DefaultDashboardScreen({super.key});

  @override
  State<DefaultDashboardScreen> createState() => _DefaultDashboardScreenState();
}

class _DefaultDashboardScreenState extends State<DefaultDashboardScreen> {
  // Tracks state for the ProfileBottomSheet
  bool _isTeamLeader = false; 

  @override
  void initState() {
    super.initState();
    // Check if new user (optional: simple check to show getting started)
    _checkNewUser();
  }

  void _checkNewUser() async {
    // We can add logic here if we want to show the Getting Started dialog 
    // strictly for new users, but the logic below handles the "No Pond" case.
  }

  void _showGettingStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const GettingStartedDialog(),
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
          assignedPond: null, // We pass null because the stream handles the actual logic now
          onRoleChanged: (isLeader) {
            // The StreamBuilder will automatically update the UI, 
            // so we just need to close the sheet.
            setState(() => _isTeamLeader = isLeader);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not Authenticated")));
    }

    // [FIX] Use StreamBuilder to listen to real-time changes in User Profile
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingOverlay());
        }

        // 2. Error State
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Error: ${snapshot.error}")));
        }

        // 3. Document missing (e.g., race condition during sign up)
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: LoadingOverlay());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final role = data['role'] ?? 'member';
        final assignedPond = data['assignedPond'];
        final String currentLeaderName = data['fullName'] ?? "Me";

        // Update local state for the profile sheet
        // We use a post-frame callback to avoid setState during build if needed, 
        // but simple assignment is fine since we don't rebuild based on this variable immediately.
        _isTeamLeader = (role == 'leader');

        // --- ROUTING LOGIC ---

        // CASE 1: User has a Pond Assigned -> Show Monitoring
        if (assignedPond != null) {
          if (role == 'leader') {
             return MonitoringPage(
                pondLetter: assignedPond,
                leaderName: currentLeaderName,
                isLeader: true,
              );
          } else {
            // If member, we need to fetch the leader's name asynchronously or show a placeholder.
            // To keep it reactive, we can fetch the leader name inside MonitoringPage or 
            // use a FutureBuilder here. For simplicity/performance, we pass a placeholder 
            // or fetch it. Since MonitoringPage expects a string, let's fetch it:
            
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where('assignedPond', isEqualTo: assignedPond)
                  .where('role', isEqualTo: 'leader')
                  .limit(1)
                  .get(),
              builder: (context, leaderSnapshot) {
                String fetchedLeaderName = "Leader";
                if (leaderSnapshot.hasData && leaderSnapshot.data!.docs.isNotEmpty) {
                  fetchedLeaderName = leaderSnapshot.data!.docs.first['fullName'] ?? "Leader";
                }
                
                return MonitoringPage(
                  pondLetter: assignedPond,
                  leaderName: fetchedLeaderName,
                  isLeader: false,
                );
              },
            );
          }
        }

        // CASE 2: No Pond Assigned
        
        // If Leader -> Show Leader Dashboard (Pond Selection)
        if (role == 'leader') {
          return const LeaderDashboard();
        }

        // If Member -> Show "No Pond Assigned" Screen
        // Check if we should show the onboarding dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // You might want to use a flag in SharedPreferences to show this only once
          // _showGettingStartedDialog(context); 
        });

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
                  children: const [
                    Text('PondStat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Text('Dashboard', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                onPressed: () => _showProfileSheet(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: const NoPondAssignedWidget(),
        );
      },
    );
  }
}