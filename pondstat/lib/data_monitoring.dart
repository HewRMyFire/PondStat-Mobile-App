import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonitoringPage extends StatefulWidget {
  final String pondLetter;
  final String leaderName;

  const MonitoringPage({
    super.key,
    required this.pondLetter,
    required this.leaderName,
  });

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final List<Map<String, dynamic>> _dailyParameters = const [
    {
      'label': 'Water Temperature',
      'icon': Icons.thermostat_outlined,
      'unit': '°C',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Air Temperature',
      'icon': Icons.air_outlined,
      'unit': '°C',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'pH Level',
      'icon': Icons.science_outlined,
      'unit': '',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Salinity',
      'icon': Icons.waves_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Feeding Time',
      'icon': Icons.local_dining_outlined,
      'unit': 'kg',
      'keyboardType': TextInputType.number
    },
  ];

  final List<Map<String, dynamic>> _weeklyParameters = const [
    {
      'label': 'Microbe Count',
      'icon': Icons.mic_outlined,
      'unit': 'cells/ml',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Phytoplankton Count',
      'icon': Icons.nature_outlined,
      'unit': 'cells/ml',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Zooplankton Count',
      'icon': Icons.pets_outlined,
      'unit': 'ind/L',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Avg Body Weight',
      'icon': Icons.fitness_center_outlined,
      'unit': 'g',
      'keyboardType': TextInputType.number
    },
  ];

  final List<Map<String, dynamic>> _biweeklyParameters = const [
    {
      'label': 'Dissolved O2',
      'icon': Icons.opacity_outlined,
      'unit': 'mg/L',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Ammonia',
      'icon': Icons.warning_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Nitrate',
      'icon': Icons.water_drop_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Nitrite',
      'icon': Icons.water_drop_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Alkalinity',
      'icon': Icons.balance_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Phosphate',
      'icon': Icons.data_usage_outlined,
      'unit': 'ppm',
      'keyboardType': TextInputType.number
    },
    {
      'label': 'Ca-Mg Ratio',
      'icon': Icons.ac_unit_outlined,
      'unit': 'ratio',
      'keyboardType': TextInputType.text
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddDataOverlay() {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a day on the calendar first.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Data for ${_selectedDay!.month}/${_selectedDay!.day}/${_selectedDay!.year}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Select Parameter for ${_getTabTitle(_tabController.index)}",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(),
                _buildOverlayContent(_tabController.index),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

void _showParameterInputOverlay(Map<String, dynamic> parameter) {
  Navigator.pop(context); // close the parameter list modal

  final String label = parameter['label'];
  final String unit = parameter['unit'] as String;
  final TextInputType keyboardType = parameter['keyboardType'] as TextInputType;
  final List<String> points = const ['A', 'B', 'C', 'D'];

  final String dateString =
      "${_selectedDay!.month}/${_selectedDay!.day}/${_selectedDay!.year}";

  TimeOfDay? selectedTime = TimeOfDay.now();
  Map<String, TextEditingController> valueControllers = {
    for (var p in points) p: TextEditingController()
  };

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          scrollable: true,
          title: Text('Record $label ${unit.isNotEmpty ? "($unit)" : ""}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Date: $dateString"),
              const Divider(),

              // ONE TIME PICKER FOR ALL
              TextButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
                child: Text(
                  selectedTime != null
                      ? "Selected Time: ${selectedTime!.format(context)}"
                      : "Select Time",
                ),
              ),

              const SizedBox(height: 10),

              // VALUE FIELDS FOR EACH POINT
              Column(
                children: points.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: valueControllers[p],
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        labelText: "Point $p Value ($unit)",
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  );
                }).toList(),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Saved $label at ${selectedTime!.format(context)} (Mock Save)",
                    ),
                  ),
                );
              },
              child: const Text("Save"),
            )
          ],
        ),
      );
    },
  );
}

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return "Daily Monitoring";
      case 1:
        return "Weekly Analysis";
      case 2:
        return "Biweekly Report";
      default:
        return "";
    }
  }

  Widget _buildOverlayContent(int index) {
    List<Map<String, dynamic>> parameters;
    switch (index) {
      case 0:
        parameters = _dailyParameters;
        break;
      case 1:
        parameters = _weeklyParameters;
        break;
      case 2:
        parameters = _biweeklyParameters;
        break;
      default:
        return const Text("Select a tab to add data.");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.5,
      ),
      itemCount: parameters.length,
      itemBuilder: (context, i) {
        final param = parameters[i];
        return InkWell(
          onTap: () => _showParameterInputOverlay(param),
          child: Card(
            elevation: 2,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Icon(param['icon'] as IconData, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        param['label'] as String,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _parameterInputField(String label, TextInputType keyboardType) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      ),
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
            const Text("Monitoring", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Pond ${widget.pondLetter} – ${widget.leaderName}'s Team", style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: _showAddDataOverlay),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.blue,
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab, // ← FULL-WIDTH INDICATOR
              indicator: const BoxDecoration(
                color: Color.fromARGB(238, 255, 255, 255),
              ),
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: "Daily"),
                Tab(text: "Weekly"),
                Tab(text: "Biweekly"),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
                    _focusedDay = focusedDay;
                  });
                },
              ),
            ),
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [_dailyTab(), _weeklyTab(), _biweeklyTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoCard("6:30 AM", "Water Temp: 28°C / Air Temp: 32°C\npH: 7.8 / Salinity: 35ppm\n(Avg across Points A, B, C, D)"),
          _infoCard("4:00 PM", "Water Temp: 27°C / Air Temp: 29°C\npH: 7.7 / Salinity: 35ppm\n(Avg across Points A, B, C, D)"),
        ],
      ),
    );
  }

  Widget _weeklyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoCard("5:40 AM", "Microbe Count: 500k cells/ml\nPhytoplankton: 80k cells/ml\nZooplankton: 10k ind/L\nAvg Body Weight: 120g"),
          _infoCard("3:59 PM", "Microbe Count: 540k cells/ml\nPhytoplankton: 83k cells/ml\nZooplankton: 11k ind/L\nAvg Body Weight: 110g"),
        ],
      ),
    );
  }

  Widget _biweeklyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _infoCard("7:21 AM", "Dissolved O2: 7.2mg/L\nAmmonia: 0.05ppm\nNitrate: 5ppm\nNitrite: 0.1ppm\nAlkalinity: 120ppm\nPhosphate: 0.3ppm\nCa-Mg Ratio: 3.5:1"),
          _infoCard("6:21 PM", "Dissolved O2: 7.5mg/L\nAmmonia: 0.02ppm\nNitrate: 6ppm\nNitrite: 0.12ppm\nAlkalinity: 123ppm\nPhosphate: 0.31ppm\nCa-Mg Ratio: 4:1")
        ],
      ),
    );
  }

  Widget _infoCard(String title, String content) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side: title + content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(content, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

              // Right side: Edit + Delete buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Edit pressed (Mock)")),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Delete pressed (Mock)")),
                      );
                    },
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

