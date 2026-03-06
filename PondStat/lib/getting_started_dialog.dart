import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GettingStartedDialog extends StatelessWidget {
  const GettingStartedDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('hasSeenTutorial') ?? false;

    if (!hasSeenTutorial) {
      await prefs.setBool('hasSeenTutorial', true);

      if (context.mounted) {
        showManual(context);
      }
    }
  }

  static void showManual(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const GettingStartedDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: const [
          Icon(Icons.waves, color: Colors.blue),
          SizedBox(width: 8),
          Text("Welcome to PondStat"),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Here is a quick guide on how to use the app:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.add_circle_outline, color: Colors.blue),
              title: Text("1. Create a Pond"),
              subtitle: Text(
                "Use the + button on the dashboard to set up your first pond.",
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_note, color: Colors.green),
              title: Text("2. Log Data"),
              subtitle: Text(
                "Record daily, weekly, and biweekly parameters like pH, Temp, and DO2.",
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.group_add_outlined, color: Colors.orange),
              title: Text("3. Invite Team"),
              subtitle: Text(
                "Add members to help you monitor and manage the pond.",
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            "Got it!",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}