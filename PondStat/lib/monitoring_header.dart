import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firestore_helper.dart';

class MonitoringHeader extends StatelessWidget {
  final String pondName;
  final VoidCallback onProfileTap;

  const MonitoringHeader({
    super.key,
    required this.pondName,
    required this.onProfileTap,
    });

    Widget _buildSyncStatus() {
        return StreamBuilder<QuerySnapshot>(
            stream: FirestoreHelper.measurementsCollection
                .limit(1)
                .snapshots(includeMetadataChanges: true),
            builder: (context, snapshot) {

                bool hasPendingWrites =
                    snapshot.hasData &&
                    snapshot.data!.metadata.hasPendingWrites;

                return Tooltip(
                    message: hasPendingWrites
                        ? "Saving locally (Offline)"
                        : "Synced to Cloud",
                    child: Row(
                        children: [
                            Icon(
                                hasPendingWrites
                                    ? Icons.cloud_upload_outlined
                                    : Icons.cloud_done_outlined,
                                color: hasPendingWrites
                                    ? Colors.orange[300]
                                    : Colors.lightGreenAccent,
                                size: 20,
                            ),

                            if (hasPendingWrites) ...[
                                const SizedBox(width: 4),

                                Text(
                                    "Offline mode",
                                    style: TextStyle(
                                        color: Colors.orange[300],
                                        fontSize: 10,
                                    ),
                                ),
                            ],
                        ],
                    ),
                );
            },
        );
    }

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
            ),
            child: Row(
                children: [

                    IconButton(
                        icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(context),
                    ),

                    Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                        ),
                        child: const Icon(
                            Icons.waves,
                            color: Colors.white,
                            size: 24,
                        ),
                    ),

                    const SizedBox(width: 12),

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            const Text(
                                "PondStat",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                ),
                            ),

                            _buildSyncStatus(),
                        ],
                    ),

                    const Spacer(),

                    GestureDetector(
                        onTap: onProfileTap,
                        child: const Icon(
                            Icons.person_outline,
                            color: Colors.white,
                            size: 30,
                        ),
                    ),
                ],
            ),
        );
    }
}