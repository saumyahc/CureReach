import 'package:flutter/material.dart';

class EmergencyHotlinesPage extends StatefulWidget {
  const EmergencyHotlinesPage({super.key});

  @override
  _EmergencyHotlinesPageState createState() => _EmergencyHotlinesPageState();
}

class _EmergencyHotlinesPageState extends State<EmergencyHotlinesPage> {
  final TextEditingController _searchController = TextEditingController();

  // List of emergency hotlines
  List<Map<String, String>> allHotlines = [
    {"service": "National Emergency Number", "number": "112"},
    {"service": "Police", "number": "100"},
    {"service": "Fire Brigade", "number": "101"},
    {"service": "Ambulance", "number": "102"},
    {"service": "Disaster Management", "number": "108"},
    {"service": "Women’s Helpline (All India)", "number": "1091"},
    {"service": "Women’s Domestic Abuse Helpline", "number": "181"},
    {"service": "Child Helpline", "number": "1098"},
    {"service": "Senior Citizen Helpline", "number": "14567"},
    {"service": "AIDS Helpline", "number": "1097"},
    {"service": "Mental Health Helpline (Kiran)", "number": "1800-599-0019"},
    {"service": "Blood Bank Information", "number": "1910"},
    {
      "service": "National Poisons Information Centre",
      "number": "1800-116-117",
    },
    {"service": "Railway Helpline", "number": "139"},
    {"service": "Road Accident Emergency Service", "number": "1073"},
    {"service": "Cyber Crime Helpline", "number": "1930"},
    {"service": "Anti-Corruption Helpline", "number": "1064"},
    {"service": "Tourist Helpline", "number": "1363"},
    {"service": "Gas Leakage Emergency (LPG Helpline)", "number": "1906"},
    {"service": "Election Commission Helpline", "number": "1950"},
  ];

  List<Map<String, String>> filteredHotlines = [];

  @override
  void initState() {
    super.initState();
    filteredHotlines = allHotlines;
  }

  void _filterHotlines(String query) {
    setState(() {
      filteredHotlines =
          allHotlines
              .where(
                (hotline) => hotline["service"]!.toLowerCase().contains(
                  query.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Hotlines"),
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterHotlines,
              decoration: InputDecoration(
                hintText: "Search for a service...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // List of hotlines
          Expanded(
            child: ListView.builder(
              itemCount: filteredHotlines.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.phone, color: Colors.red),
                    title: Text(
                      filteredHotlines[index]["service"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("📞 ${filteredHotlines[index]["number"]!}"),
                    trailing: IconButton(
                      icon: Icon(Icons.call, color: Colors.green),
                      onPressed: () {
                        // Dial the number when pressed
                        _makeCall(filteredHotlines[index]["number"]!);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to make a call
  void _makeCall(String number) {
    print(
      "Calling $number...",
    ); // Replace this with actual call functionality if needed
  }
}
