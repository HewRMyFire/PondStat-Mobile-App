import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamMgmt extends StatefulWidget {
  final String selectedPanel; // This is the Pond Name (e.g., "Pond 1")

  const TeamMgmt({super.key, required this.selectedPanel});

  @override
  State<TeamMgmt> createState() => _TeamMgmtState();
}

class _TeamMgmtState extends State<TeamMgmt> {
  final TextEditingController searchController = TextEditingController();
  
  // List to hold search results
  List<DocumentSnapshot> searchResults = [];
  bool isSearching = false;
  bool showDropdown = false;

  // 🔍 Filter Search: Queries Firestore for users
  void _filterSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        showDropdown = false;
      });
      return;
    }

    // Simple search by student number
    // For a more advanced search (like partial name matching), you might need a third-party service like Algolia
    // or store a normalized 'searchKeywords' array in Firestore.
    // Here we search for student numbers starting with the query.
    
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('studentNumber', isGreaterThanOrEqualTo: query)
        .where('studentNumber', isLessThan: '${query}z')
        .limit(5) // Limit results to avoid overloading the dropdown
        .get();

    setState(() {
      searchResults = snapshot.docs;
      showDropdown = searchResults.isNotEmpty;
    });
  }

  // 📋 Select student and Assign to Pond
  void _selectStudent(DocumentSnapshot userDoc) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String currentPond = userData['assignedPond'] ?? '';
    final String uid = userDoc.id;
    final String name = userData['fullName'] ?? 'Student';

    setState(() {
      searchController.text = "$name (${userData['studentNumber']})";
      showDropdown = false; // Hide dropdown after selection
    });

    if (currentPond.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name is already assigned to $currentPond')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'assignedPond': widget.selectedPanel});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to ${widget.selectedPanel}')),
      );
      
      // Clear search
      searchController.clear();
      setState(() => searchResults = []);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add member: $e')),
      );
    }
  }

  // 🗑️ Remove Member
  void _confirmRemoval(String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Remove Member"),
        content: Text("Remove $name from your team?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'assignedPond': null}); // Set back to null

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing member: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Manage Team", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.selectedPanel, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.search, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Select Collaborators",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Stack allows the dropdown to float over other content
            Stack(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: _filterSearch,
                  decoration: InputDecoration(
                    hintText: "Search by Student Number",
                    prefixIcon: const Icon(Icons.person_search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                
                if (showDropdown)
                  Positioned(
                    top: 60, // Place below the text field
                    left: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final doc = searchResults[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.person_outline, color: Colors.blue),
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

            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(Icons.group, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Current Team Members",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // REAL-TIME LIST OF MEMBERS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('assignedPond', isEqualTo: widget.selectedPanel)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  final members = snapshot.data!.docs;

                  if (members.isEmpty) {
                    return const Center(child: Text("No members assigned yet.", style: TextStyle(color: Colors.black54)));
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final memberDoc = members[index];
                      final memberData = memberDoc.data() as Map<String, dynamic>;
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white)
                          ),
                          title: Text(memberData['fullName'] ?? 'Unknown'),
                          subtitle: Text(memberData['studentNumber'] ?? ''),
                          trailing: memberData['role'] == 'leader' 
                            ? const Chip(
                                label: Text('Leader', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.blue,
                              )
                            : IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => _confirmRemoval(memberDoc.id, memberData['fullName'] ?? 'Member'),
                              ),
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