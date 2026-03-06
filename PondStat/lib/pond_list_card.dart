import 'package:flutter/material.dart';
import 'monitoring/data_monitoring.dart';

class PondListCard extends StatelessWidget {
  final String pondId;
  final String pondName;
  final String species;
  final String userRole;

  const PondListCard({
    super.key,
    required this.pondId,
    required this.pondName,
    required this.species,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.water, color: Colors.blue),
        ),
        title: Text(
          pondName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Species: $species',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'Role: ${userRole.toUpperCase()}',
                style: TextStyle(
                  color: userRole == 'owner' ? Colors.green[700] : Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MonitoringPage(
                pondId: pondId,
                pondName: pondName,
                userRole: userRole,
              )
            )
          );
        },
      ),
    );
  }
}