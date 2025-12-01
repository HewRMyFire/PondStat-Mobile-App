import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'team_mgmt.dart';

class MonitoringPage extends StatefulWidget {
  final String pondLetter; // e.g., "Pond 1"
  final String leaderName;
  final bool isLeader;

  const MonitoringPage({
    super.key,
    required this.pondLetter,
    required this.leaderName,
    required this.isLeader,
  });

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Parameters definitions
  final List<Map<String, dynamic>> _dailyParameters = const [
    {'label': 'Water Temperature', 'icon': Icons.thermostat, 'unit': '°C', 'keyboardType': TextInputType.number},
    {'label': 'Air Temperature', 'icon': Icons.air, 'unit': '°C', 'keyboardType': TextInputType.number},
    {'label': 'pH Level', 'icon': Icons.science, 'unit': '', 'keyboardType': TextInputType.number},
    {'label': 'Salinity', 'icon': Icons.waves, 'unit': 'ppm', 'keyboardType': TextInputType.number},
    {'label': 'Feeding', 'icon': Icons.restaurant, 'unit': 'kg', 'keyboardType': TextInputType.number},
  ];

  // (Keeping Weekly and Biweekly lists abbreviated for brevity, logic is identical)
  final List<Map<String, dynamic>> _weeklyParameters = const [
    {'label': 'Microbe Count', 'icon': Icons.bug_report, 'unit': 'cells/ml', 'keyboardType': TextInputType.number},
    {'label': 'Avg Body Weight', 'icon': Icons.scale, 'unit': 'g', 'keyboardType': TextInputType.number},
  ];

  final List<Map<String, dynamic>> _biweeklyParameters = const [
    {'label': 'Dissolved O2', 'icon': Icons.water, 'unit': 'mg/L', 'keyboardType': TextInputType.number},
    {'label': 'Ammonia', 'icon': Icons.warning, 'unit': 'ppm', 'keyboardType': TextInputType.number},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
  }

  // 🔥 SAVE DATA TO FIRESTORE
  void _saveMeasurement(String label, String value, String unit, String type) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_selectedDay == null) return;

    // Normalize date to YYYY-MM-DD string for easier querying
    final String dateKey = "${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}";

    try {
      await FirebaseFirestore.instance.collection('measurements').add({
        'pond': widget.pondLetter,
        'dateKey': dateKey,
        'timestamp': Timestamp.fromDate(_selectedDay!), // The logical date of record
        'recordedAt': FieldValue.serverTimestamp(), // When it was actually typed
        'recordedBy': user.uid,
        'recorderName': user.displayName ?? 'Unknown',
        'type': type, // 'daily', 'weekly', 'biweekly'
        'parameter': label,
        'value': double.tryParse(value) ?? 0.0,
        'unit': unit,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Saved!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showAddDataOverlay() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a date first.')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Add ${_getTabTitle(_tabController.index)} Data", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            _buildParameterGrid(_tabController.index),
          ],
        ),
      ),
    );
  }

  String _getTabTitle(int index) => ["Daily", "Weekly", "Biweekly"][index];

  Widget _buildParameterGrid(int index) {
    List<Map<String, dynamic>> params = index == 0 ? _dailyParameters : (index == 1 ? _weeklyParameters : _biweeklyParameters);
    String type = index == 0 ? 'daily' : (index == 1 ? 'weekly' : 'biweekly');

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: params.map((p) => ActionChip(
        avatar: Icon(p['icon'] as IconData, size: 16),
        label: Text(p['label']),
        onPressed: () => _showInputDialog(p, type),
      )).toList(),
    );
  }

  void _showInputDialog(Map<String, dynamic> param, String type) {
    Navigator.pop(context); // Close bottom sheet
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Enter ${param['label']}"),
        content: TextField(
          controller: controller,
          keyboardType: param['keyboardType'],
          decoration: InputDecoration(labelText: "Value in ${param['unit']}"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveMeasurement(param['label'], controller.text, param['unit'], type);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.pondLetter, style: const TextStyle(fontSize: 16)),
            Text("Leader: ${widget.leaderName}", style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          // If Leader, show Manage Team button
          if (widget.isLeader)
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: "Manage Team",
              onPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (_) => TeamMgmt(selectedPanel: widget.pondLetter))
                );
              },
            ),
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDataOverlay),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Daily"), Tab(text: "Weekly"), Tab(text: "Biweekly")],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) => setState(() {
              _selectedDay = selected;
              _focusedDay = focused;
            }),
            calendarFormat: CalendarFormat.twoWeeks,
          ),
          const Divider(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDataList('daily'),
                _buildDataList('weekly'),
                _buildDataList('biweekly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FETCH AND DISPLAY DATA
  Widget _buildDataList(String type) {
    if (_selectedDay == null) return const Center(child: Text("Select a date"));
    final String dateKey = "${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('measurements')
          .where('pond', isEqualTo: widget.pondLetter)
          .where('type', isEqualTo: type)
          .where('dateKey', isEqualTo: dateKey)
          .orderBy('recordedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) return Center(child: Text("No $type data for this date"));

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blue),
              title: Text("${data['parameter']}: ${data['value']} ${data['unit']}"),
              subtitle: Text("Recorded by: ${data['recorderName']}"),
              trailing: widget.isLeader 
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    onPressed: () => doc.reference.delete(),
                  )
                : null,
            );
          }).toList(),
        );
      },
    );
  }
}