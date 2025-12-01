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

  // 🔍 Filter Search: Queries Firestore for users
  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() => isSearching = true);

    // Simple search by student number OR full name
    // Note: Firestore doesn't support native OR queries easily across fields without separate queries
    // We will search by Student Number first as it is unique
    
    final studentNumSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('studentNumber', isEqualTo: query)
        .get();

    if (studentNumSnapshot.docs.isNotEmpty) {
      setState(() {
        searchResults = studentNumSnapshot.docs;
        isSearching = false;
      });
    } else {
      // If not found by number, try Name (exact match or simple prefix)
      // For prefix search: where('fullName', isGreaterThanOrEqualTo: query).where('fullName', isLessThan: query + 'z')
      final nameSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('fullName', isGreaterThanOrEqualTo: query)
          .where('fullName', isLessThan: '${query}z')
          .get();
      
      setState(() {
        searchResults = nameSnapshot.docs;
        isSearching = false;
      });
    }
  }

  // 📋 Select student and Assign to Pond
  void _addMember(DocumentSnapshot userDoc) async {
    final userData = userDoc.data() as Map<String, dynamic>;
    final String currentPond = userData['assignedPond'] ?? '';
    final String uid = userDoc.id;
    final String name = userData['fullName'] ?? 'Student';

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
            Text(widget.selectedPanel, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onSubmitted: _performSearch, // Search on Enter
              decoration: InputDecoration(
                hintText: "Search by Student No. or Name",
                prefixIcon: const Icon(Icons.person_search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _performSearch(searchController.text.trim()),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            // Search Results Dropdown (Simulated as list below for simplicity)
            if (searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Search Results:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ...searchResults.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        dense: true,
                        title: Text("${data['fullName']} (${data['studentNumber']})"),
                        subtitle: Text(data['role'] ?? 'member'),
                        trailing: const Icon(Icons.add_circle, color: Colors.green),
                        onTap: () => _addMember(doc),
                      );
                    }).toList(),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            const Text("Current Team Members", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),

            // REAL-TIME LIST OF MEMBERS
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('assignedPond', isEqualTo: widget.selectedPanel)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text("Something went wrong");
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  final members = snapshot.data!.docs;

                  if (members.isEmpty) {
                    return const Center(child: Text("No members assigned yet."));
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final memberDoc = members[index];
                      final memberData = memberDoc.data() as Map<String, dynamic>;
                      
                      // Skip if it's the current user (leader) - optional
                      // if (memberDoc.id == FirebaseAuth.instance.currentUser?.uid) return SizedBox.shrink();

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(memberData['fullName'] ?? 'Unknown'),
                          subtitle: Text(memberData['studentNumber'] ?? ''),
                          trailing: memberData['role'] == 'leader' 
                            ? const Chip(label: Text('Leader'))
                            : IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => _confirmRemoval(memberDoc.id, memberData['fullName']),
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