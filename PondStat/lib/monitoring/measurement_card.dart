import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeasurementCard extends StatelessWidget {
  final String time;
  final String title;
  final String content;
  final bool canEdit;
  final List<QueryDocumentSnapshot> groupDocs;
  final VoidCallback onEdit;

  const MeasurementCard({
    super.key,
    required this.time,
    required this.title,
    required this.content,
    required this.canEdit,
    required this.groupDocs,
    required this.onEdit,
  });

  void _confirmGroupDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Data"),
        content: const Text("Are you sure you want to delete this measurement?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              final batch = FirebaseFirestore.instance.batch();
              for (var doc in groupDocs) {
                batch.delete(doc.reference);
              }
              batch.commit();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Entry deleted")),
              );
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(title, style: const TextStyle(fontSize: 14)),
                    Text(content, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              if (canEdit)
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmGroupDelete(context),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}