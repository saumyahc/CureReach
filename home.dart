import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'symptom_checker_chatbot.dart';
import 'subsidyfinder.dart';
import 'specialty_page.dart'; 
import 'profile.dart';
import 'peergroupchat.dart';
import 'emergency.dart'; 
import 'nutrition_plan_chatbot.dart'; // Import NutritionPlanChatbot

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString("userEmail");

    if (storedEmail != null) {
      setState(() {
        userEmail = storedEmail;
      });
    } else {
      DatabaseReference dbRef = FirebaseDatabase.instance.ref("patients");
      DatabaseEvent event = await dbRef.once();
      Map<dynamic, dynamic>? users =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (users != null) {
        for (var entry in users.entries) {
          if (entry.value['isLoggedIn'] == true) {
            await prefs.setString("userEmail", entry.value['email']);
            setState(() {
              userEmail = entry.value['email'];
            });
            break;
          }
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("CureReach"),
        backgroundColor: Colors.blue,
        actions: [
          if (userEmail != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove("userEmail");
                setState(() {
                  userEmail = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              if (userEmail != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userEmail: userEmail!),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User not logged in!")),
                );
              }
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      if (userEmail != null)
                        Text(
                          "Welcome, $userEmail!",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 110,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCategory(
                              context,
                              "Cardiology",
                              "assets/cardiology.png",
                            ),
                            _buildCategory(
                              context,
                              "Urology",
                              "assets/urology.png",
                            ),
                            _buildCategory(
                              context,
                              "Radiology",
                              "assets/radiology.png",
                            ),
                            _buildCategory(
                              context,
                              "Ophthalmology",
                              "assets/ophthalmology.png",
                            ),
                            _buildCategory(
                              context,
                              "Obstetrics",
                              "assets/obstetrician.png",
                            ),
                            _buildCategory(
                              context,
                              "Dermatology",
                              "assets/dermatology.png",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildFeatureCard(
                        context,
                        "Symptom Checker",
                        "Get AI-powered health guidance.",
                        Icons.medical_services,
                        Colors.blueAccent,
                        true,
                      ),
                      _buildFeatureCard(
                        context,
                        "Personalized Nutrition",
                        "Find meal plans for your goals.",
                        Icons.restaurant_menu,
                        Colors.green,
                        false, 
                        isNutrition: true,  // <-- Added
                      ),
                      _buildFeatureCard(
                        context,
                        "Subsidy Finder",
                        "Locate and apply for subsidies.",
                        Icons.local_hospital,
                        Colors.orange,
                        false,
                        isSubsidyFinder: true,
                      ),
                      _buildFeatureCard(
                        context,
                        "Peer Support Groups",
                        "Join mental health support groups.",
                        Icons.groups,
                        Colors.purple,
                        false,
                        isPeerGroup: true,
                      ),
                      _buildFeatureCard(
                        context,
                        "Emergency Help",
                        "Get crisis intervention support.",
                        Icons.warning,
                        Colors.redAccent,
                        false,
                        isEmergency: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildCategory(BuildContext context, String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialtyPage(specialty: name),
            ),
          );
        },
        child: Column(
          children: [
            Image.asset(imagePath, width: 60, height: 60),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    bool navigateToChat, {
    bool isSubsidyFinder = false,
    bool isPeerGroup = false,
    bool isEmergency = false,
    bool isNutrition = false,  // <-- Added
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          if (isSubsidyFinder) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SubsidyFinderPage()),
            );
          } else if (isPeerGroup) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PeerGroupChatScreen(groupId: "default_group"),
              ),
            );
          } else if (isEmergency) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EmergencyHotlinesPage()),
            );
          } else if (isNutrition) {  // <-- Navigates to NutritionPlanChatbot
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NutritionPlanChatbot()),
            );
          } else if (navigateToChat) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SymptomCheckerChatbot()),
            );
          }
        },
      ),
    );
  }
}
