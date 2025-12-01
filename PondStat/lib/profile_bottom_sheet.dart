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
          
          // User Info
          Row(
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