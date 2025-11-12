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

  final List<String> allStudents = [
    "John Doe - 2021001",
    "Jane Smith - 2021002",
    "Carlos Reyes - 2021003",
    "Maria Lopez - 2021004",
    "Rico Dela Cruz - 2021005",
    "Lara Santos - 2021006",
    "Mark Villanueva - 2021007",
  ];

  List<String> teamMembers = [
    "John Doe - 2021001",
    "Jane Smith - 2021002",
  ];

  List<String> filteredStudents = [];
  bool showDropdown = false;

  @override
  void initState() {
    super.initState();
    filteredStudents = List.from(allStudents);
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => showDropdown = false);
      return;
    }

    final results = allStudents.where((student) {
      return student.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredStudents = results;
      showDropdown = results.isNotEmpty;
    });
  }

  // 📋 Select student from dropdown
  void _selectStudent(String student) async {
    setState(() {
      searchController.text = student;
      showDropdown = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected: $student')),
    );

    // ---------------- OPTION A ADDED ----------------
    try {
      // Assuming student number is used as UID
      final studentNumber = student.split('-').last.trim();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentNumber) // replace with actual UID if you have
          .update({'assignedPond': widget.selectedPanel});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$student assigned to ${widget.selectedPanel}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign $student: $e')),
      );
    }
    // -------------------------------------------------
  }

  void _confirmRemoval(String student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Remove Member"),
        content: Text(
          "Are you sure you want to remove $student from your team?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(student);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  void _removeMember(String student) {
    setState(() {
      teamMembers.remove(student);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$student removed!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manage Team Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${widget.selectedPanel} - Leader’s Name",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                TextField(
                  controller: searchController,
                  onChanged: _filterSearch,
                  decoration: InputDecoration(
                    hintText: "Search by name or by student number",
                    prefixIcon: const Icon(Icons.person_search),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                if (showDropdown)
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue, width: 1),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return ListTile(
                            leading: const Icon(Icons.person_outline,
                                color: Colors.blue),
                            title: Text(student),
                            onTap: () => _selectStudent(student),
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
                  "Team Members",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: teamMembers.isEmpty
                  ? const Center(
                      child: Text(
                        "No team members yet.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: teamMembers.length,
                      itemBuilder: (context, index) {
                        final student = teamMembers[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.blue),
                            title: Text(student),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: Colors.red),
                              onPressed: () => _confirmRemoval(student),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Continuing to next step...")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}