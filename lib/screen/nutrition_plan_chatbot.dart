import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NutritionPlanChatbot extends StatefulWidget {
  const NutritionPlanChatbot({super.key});

  @override
  _NutritionPlanChatbotState createState() => _NutritionPlanChatbotState();
}

class _NutritionPlanChatbotState extends State<NutritionPlanChatbot> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch response from Firestore
  Future<String> _getNutritionPlan(String userInput) async {
    try {
      QuerySnapshot nutritionDocs =
          await _firestore.collection("Nutrition_plan").get();

      for (var doc in nutritionDocs.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        print("Fetched data: $data"); // Debugging: Print retrieved data

        if (data.containsKey("question") && data.containsKey("answer")) {
          // Direct match
          if (data["question"].toString().toLowerCase() ==
              userInput.toLowerCase()) {
            return data["answer"];
          }

          // Match with synonyms (if available)
          if (data.containsKey("synonym")) {
            List<dynamic> synonyms = data["synonym"];
            for (var synonym in synonyms) {
              if (synonym.toString().toLowerCase() == userInput.toLowerCase()) {
                return data["answer"];
              }
            }
          }
        }
      }
      return "Sorry, I couldn't find a nutrition plan for that. Please consult a dietitian.";
    } catch (e) {
      print("Error fetching data: $e");
      return "Oops! Something went wrong while fetching the data.";
    }
  }

  // Function to handle user input
  void _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _chatMessages.add({"sender": "user", "text": userMessage});
    });

    _messageController.clear();

    String botResponse = await _getNutritionPlan(userMessage);

    setState(() {
      _chatMessages.add({"sender": "bot", "text": botResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrition Plan Bot"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                bool isUser = message["sender"] == "user";

                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Ask for a nutrition plan...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
