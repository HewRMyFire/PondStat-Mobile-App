import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMgmt extends StatefulWidget {
  final String selectedPanel; 

  const TeamMgmt({super.key, required this.selectedPanel});

  @override
  State<TeamMgmt> createState() => _TeamMgmtState();
}

class _TeamMgmtState extends State<TeamMgmt> {
  final TextEditingController searchController = TextEditingController();
  
  // Stores ALL users to search locally
  List<DocumentSnapshot> allUsers = [];
  // Stores filtered results for the dropdown
  List<DocumentSnapshot> searchResults = [];
  bool showDropdown = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  // 📥 Fetch ALL users once when the page loads
  Future<void> _fetchAllUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        allUsers = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  // 🔍 Filter the local list (Supports Name & ID + Partial Matching)
  void _filterSearch(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showDropdown = false;
      });
      return;
    }

    final results = allUsers.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['fullName'] ?? '').toString().toLowerCase();
      final studentNum = (data['studentNumber'] ?? '').toString().toLowerCase();

      // ✅ CHECKS IF QUERY IS INSIDE NAME OR STUDENT NUMBER
      return name.contains(query) || studentNum.contains(query);
    }).toList();

    setState(() {
      searchResults = results;
      showDropdown = searchResults.isNotEmpty;
    });
  }

  // 📋 Select student
  void _selectStudent(DocumentSnapshot userDoc) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String currentPond = userData['assignedPond'] ?? '';
    final String uid = userDoc.id;
    final String name = userData['fullName'] ?? 'Student';

    setState(() {
      searchController.text = "$name (${userData['studentNumber']})";
      showDropdown = false;
    });

    // ... (Rest of your selection logic stays the same) ...
    // Note: Copy your previous _selectStudent logic here
    if (currentPond.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name is already assigned to $currentPond')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'assignedPond': widget.selectedPanel
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to ${widget.selectedPanel}')),
      );
      searchController.clear();
      setState(() => searchResults = []);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  // ... (Keep your _confirmRemoval and _removeMember functions exactly as they were) ...
  // 🗑️ Remove Member
  void _confirmRemoval(String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Member"),
        content: Text("Remove $name from your team?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(uid);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _removeMember(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'assignedPond': null});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed')));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text("Manage Team"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar Stack
            Stack(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: _filterSearch,
                  decoration: const InputDecoration(
                    hintText: "Search Name or Student No.",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
                if (showDropdown)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black12)],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final doc = searchResults[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(data['fullName'] ?? 'Unknown'),
                            subtitle: Text(data['studentNumber'] ?? ''),
                            onTap: () => _selectStudent(doc),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // ... (Rest of your UI for displaying Current Team Members) ...
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('assignedPond', isEqualTo: widget.selectedPanel)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final members = snapshot.data!.docs;
                  if (members.isEmpty) return const Text("No members yet.");

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final m = members[index].data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(m['fullName'] ?? ''),
                        subtitle: Text(m['studentNumber'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _confirmRemoval(members[index].id, m['fullName']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}