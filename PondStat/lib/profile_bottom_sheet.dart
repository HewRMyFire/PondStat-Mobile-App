import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- THIS MAKES THE FILE RUNNABLE FOR TESTING ---
void main() {
  runApp(
    MaterialApp(
      title: 'PondStat (Test)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const _ProfileSheetTestHarness(),
    ),
  );
}

// A helper widget to host and launch the bottom sheet
class _ProfileSheetTestHarness extends StatefulWidget {
  const _ProfileSheetTestHarness();

  @override
  State<_ProfileSheetTestHarness> createState() =>
      _ProfileSheetTestHarnessState();
}

class _ProfileSheetTestHarnessState extends State<_ProfileSheetTestHarness> {
  bool _isTeamLeader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Sheet Test')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Show Profile Bottom Sheet'),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return ProfileBottomSheet(
                  isTeamLeader: _isTeamLeader,
                  assignedPond: "Pond 1", // Replace with dynamic pond if needed
                  onRoleChanged: (isLeader) {
                    setState(() {
                      _isTeamLeader = isLeader;
                    });
                    print("Role changed to: $isLeader");
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------------

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

  @override
  void initState() {
    super.initState();
    _currentIsLeader = widget.isTeamLeader;
  }

  // --- FIRESTORE UPDATE ---
  Future<void> _updateTeamRole(bool isLeader) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final usersRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      // 1️⃣ Update the role in users collection
      await usersRef.update({'role': isLeader ? 'leader' : 'member'});

      // 2️⃣ Update the team document
      if (widget.assignedPond == null) return;

      final teamQuery = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamName', isEqualTo: widget.assignedPond)
          .limit(1)
          .get();

      if (teamQuery.docs.isEmpty) return;

      final teamDoc = teamQuery.docs.first;
      final teamRef = teamDoc.reference;
      final teamData = teamDoc.data();

      String? currentLeaderId = teamData['leaderId'];
      List memberIds = List.from(teamData['memberIds'] ?? []);

      if (isLeader) {
        // Demote previous leader if exists
        if (currentLeaderId != user.uid) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentLeaderId)
              .update({'role': 'member'});
          memberIds.add(currentLeaderId);
        }
        // Remove new leader from memberIds
        memberIds.remove(user.uid);

        await teamRef.update({
          'leaderId': user.uid,
          'memberIds': memberIds,
        });
      } else {
        // Demote current user to member
        memberIds.add(user.uid);
        await teamRef.update({
          'leaderId': null,
          'memberIds': memberIds,
        });
      }

      print('✅ Role updated successfully: $isLeader');
    } catch (e) {
      print('❌ Failed to update role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update team role')),
      );
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
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 224, 224, 224),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          _buildUserInfo(),
          const SizedBox(height: 16),
          _buildTeamRoleCard(),
          const SizedBox(height: 16),
          _buildMenuButton(
            icon: Icons.edit_outlined,
            text: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
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
            onTap: () {
              Navigator.pop(context);
              print("Sign Out Tapped");
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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matthew F. Simpas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Student #2023-09454',
              style: TextStyle(color: Colors.grey),
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
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}