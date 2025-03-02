import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomCheckerChatbot extends StatefulWidget {
  @override
  _SymptomCheckerChatbotState createState() => _SymptomCheckerChatbotState();
}

class _SymptomCheckerChatbotState extends State<SymptomCheckerChatbot> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _chatMessages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch response from Firestore
  Future<String> _getResponse(String userInput) async {
    QuerySnapshot symptomDocs = await _firestore.collection("Symptom_checker").get();

    for (var doc in symptomDocs.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Check if user input matches the stored question
      if (data["question"].toString().toLowerCase() == userInput.toLowerCase()) {
        return data["answer"];
      }

      // Check if user input matches any synonym
      List<dynamic> synonyms = data["synonyms"] ?? [];
      for (var synonym in synonyms) {
        if (synonym.toString().toLowerCase() == userInput.toLowerCase()) {
          return data["answer"];
        }
      }
    }

    return "Sorry, I couldn't find an answer for that. Please consult a doctor.";
  }

  // Function to handle user input
  void _sendMessage() async {
    String userMessage = _messageController.text.trim();
    if (userMessage.isEmpty) return;

    setState(() {
      _chatMessages.add({"sender": "user", "text": userMessage});
    });

    _messageController.clear();

    String botResponse = await _getResponse(userMessage);

    setState(() {
      _chatMessages.add({"sender": "bot", "text": botResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Checker Bot"),
        backgroundColor: Colors.blueAccent,
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
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message["text"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black),
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
                      hintText: "Type a symptom...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.blueAccent,
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
