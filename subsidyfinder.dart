import 'package:flutter/material.dart';

class SubsidyFinderPage extends StatefulWidget {
  @override
  _SubsidyFinderPageState createState() => _SubsidyFinderPageState();
}

class _SubsidyFinderPageState extends State<SubsidyFinderPage> {
  final TextEditingController _searchController = TextEditingController();

  // List of subsidies (hardcoded, no database needed)
  List<Map<String, String>> allSubsidies = [
    {
      "name": "Ayushman Bharat (PM-JAY)",
      "description": "₹5 lakh insurance for low-income families",
    },
    {
      "name": "Central Government Health Scheme (CGHS)",
      "description": "Healthcare for govt employees & pensioners",
    },
    {
      "name": "Rashtriya Swasthya Bima Yojana (RSBY)",
      "description": "Health insurance for BPL families",
    },
    {
      "name": "Pradhan Mantri Suraksha Bima Yojana (PMSBY)",
      "description": "Accidental insurance coverage",
    },
    {
      "name": "Janani Suraksha Yojana (JSY)",
      "description": "Maternity benefit for safe institutional deliveries",
    },
    {
      "name": "National Health Mission (NHM)",
      "description": "Improving healthcare in rural & urban areas",
    },
    {
      "name": "Ayushman Bharat Health & Wellness Centres (AB-HWCs)",
      "description": "Primary healthcare services",
    },
    {
      "name": "Mahatma Jyotiba Phule Jan Arogya Yojana",
      "description": "Health insurance for Maharashtra's poor",
    },
    {
      "name": "Mukhyamantri Amrutum Yojana",
      "description": "Free tertiary care for Gujarat’s poor",
    },
    {
      "name": "Bhamashah Swasthya Bima Yojana",
      "description": "Cashless healthcare for Rajasthan's low-income families",
    },
    {
      "name": "Pradhan Mantri Matru Vandana Yojana (PMMVY)",
      "description": "Cash incentive for pregnant women",
    },
    {
      "name": "Pradhan Mantri Bhartiya Janaushadhi Pariyojana (PMBJP)",
      "description": "Affordable generic medicines",
    },
    {
      "name": "Mission Indradhanush",
      "description": "Free immunization for children & pregnant women",
    },
    {
      "name": "National Mental Health Programme (NMHP)",
      "description": "Mental health services & awareness",
    },
    {
      "name": "Pradhan Mantri National Dialysis Programme",
      "description": "Free dialysis for kidney patients",
    },
    {
      "name": "National Programme for Health Care of the Elderly (NPHCE)",
      "description": "Healthcare for senior citizens",
    },
    {
      "name":
          "National Programme for Prevention & Control of Cancer, Diabetes, Cardiovascular Diseases, and Stroke (NPCDCS)",
      "description": "Non-communicable disease control",
    },
    {
      "name": "National Leprosy Eradication Programme (NLEP)",
      "description": "Free treatment & rehabilitation for leprosy",
    },
    {
      "name": "National AIDS Control Programme (NACP)",
      "description": "HIV/AIDS prevention and treatment",
    },
  ];

  List<Map<String, String>> filteredSubsidies = [];

  @override
  void initState() {
    super.initState();
    filteredSubsidies = allSubsidies;
  }

  void _filterSubsidies(String query) {
    setState(() {
      filteredSubsidies =
          allSubsidies
              .where(
                (subsidy) => subsidy["name"]!.toLowerCase().contains(
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
        title: Text("Subsidy Finder"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSubsidies,
              decoration: InputDecoration(
                hintText: "Search for a subsidy...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          // List of subsidies
          Expanded(
            child: ListView.builder(
              itemCount: filteredSubsidies.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(Icons.health_and_safety, color: Colors.green),
                    title: Text(
                      filteredSubsidies[index]["name"]!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(filteredSubsidies[index]["description"]!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
