import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileBottomSheet extends StatefulWidget {
  final bool isTeamLeader;
  final String? assignedPond;
  final Function(bool) onRoleChanged;

  const ProfileBottomSheet({
    super.key,
    required this.isTeamLeader,
    this.assignedPond,
    required this.onRoleChanged,
  });

  @override
  State<ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<ProfileBottomSheet> {
  late bool _currentIsLeader;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _currentIsLeader = widget.isTeamLeader;
  }

  // --- FIRESTORE UPDATE ---
  Future<void> _updateTeamRole(bool isLeader) async {
    if (user == null) return;

    try {
<<<<<<< HEAD
      // Simply update the role.
      // NOTE: Logic to remove/add to teams collection is simplified here. 
      // In this app structure, 'assignedPond' in the USER doc is the source of truth.
      
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        'role': isLeader ? 'leader' : 'member',
        // If demoting to member, should we clear assignedPond? 
        // Maybe keep it so they stay in the team but as a member.
        // If promoting to leader, they usually need to select a new pond.
        // For safety, let's clear assignedPond if becoming a leader so they are forced to 'Select' one via dashboard.
        'assignedPond': isLeader ? null : FieldValue.delete(), 
      });

      // Update local UI
      setState(() {
        _currentIsLeader = isLeader;
      });
      
=======
      // 1️⃣ Update the role in users collection
      // Also update assignedPond logic: if becoming a leader, clear assignedPond to force selection
      await usersRef.update({
        'role': isLeader ? 'leader' : 'member',
        'assignedPond': isLeader ? null : FieldValue.delete(), // Example logic, adjust as needed
      });

      // 2️⃣ Update the team document logic (if applicable)
      // ... (Your existing team update logic would go here if you kept it) ...
      
      if (mounted) {
         setState(() {
          _currentIsLeader = isLeader;
        });
        widget.onRoleChanged(isLeader);
      }

      print('✅ Role updated successfully: $isLeader');
>>>>>>> 6c954a5405cabe19a30222018e744370e536e310
    } catch (e) {
      print('❌ Failed to update role: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update team role')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),
<<<<<<< HEAD
          
          // User Info
          Row(
=======
          _buildUserInfo(),
          const SizedBox(height: 16),
          _buildTeamRoleCard(),
          const SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.edit_outlined,
            text: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              // Add navigation to edit profile page if it exists
              print("Edit Profile Tapped");
            },
          ),
          _buildMenuButton(
            icon: Icons.group_outlined,
            text: 'My Team',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Please contact your team leader to be assigned to a pond.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          _buildMenuButton(
            icon: Icons.logout,
            text: 'Sign Out',
            isSignOut: true,
            onTap: () async {
              // 1. Sign out from Firebase
              await FirebaseAuth.instance.signOut();
              
              // 2. Close the bottom sheet
              // The StreamBuilder in main.dart will detect the auth change and 
              // automatically switch the visible screen to AuthPage (Login).
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: const Color.fromARGB(255, 33, 130, 243),
          child: const Icon(
            Icons.person,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.displayName ?? 'User Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'No Email', // Or display student number if you store it in display name or fetch it
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamRoleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Role',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor:
                  _currentIsLeader ? Theme.of(context).primaryColor : Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              _currentIsLeader ? 'Team Leader' : 'Team Member',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _currentIsLeader ? 'Manage pond & members' : 'Contribute to team',
            ),
            trailing: Switch(
              value: _currentIsLeader,
              onChanged: (newValue) async {
                // Optimistic update
                setState(() {
                  _currentIsLeader = newValue;
                });
                widget.onRoleChanged(newValue);
                await _updateTeamRole(newValue);
              },
              activeThumbColor: Theme.of(context).primaryColor,
            ),
          ),
          if (_currentIsLeader) ...[
            const SizedBox(height: 12),
            _buildLeaderInfoBox(
              'As a leader, you can now access the leader dashboard.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderInfoBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB3E5FC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0277BD)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF01579B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    bool isSignOut = false,
    required VoidCallback onTap,
  }) {
    final Color color = isSignOut ? Colors.red[700]! : Colors.black87;
    final Color bgColor = isSignOut ? Colors.white : Colors.grey[100]!;
    final Border? border = isSignOut ? Border.all(color: Colors.red[300]!) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: border,
          ),
          child: Row(
>>>>>>> 6c954a5405cabe19a30222018e744370e536e310
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Role Toggle Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_currentIsLeader ? 'Team Leader' : 'Team Member', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(_currentIsLeader ? 'Switch off to become a member' : 'Switch on to become a leader'),
              trailing: Switch(
                value: _currentIsLeader,
                onChanged: (val) => _updateTeamRole(val),
                activeColor: Colors.blue,
              ),
            ),
          ),

          const SizedBox(height: 16),
          
          // Sign Out Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}