import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PeerGroupChatScreen extends StatefulWidget {
  final String groupId;

  const PeerGroupChatScreen({super.key, required this.groupId});

  @override
  _PeerGroupChatScreenState createState() => _PeerGroupChatScreenState();
}

class _PeerGroupChatScreenState extends State<PeerGroupChatScreen> {
  final TextEditingController messageController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  bool isAnonymous = true; // Default to anonymous mode

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    String senderName =
        isAnonymous
            ? "Anonymous"
            : user?.displayName ?? "User-${user?.uid.substring(0, 5)}";

    String messageId =
        dbRef.child("groups/${widget.groupId}/messages").push().key!;
    await dbRef.child("groups/${widget.groupId}/messages/$messageId").set({
      "userId": senderName,
      "text": messageController.text.trim(),
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Peer Support Group"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  dbRef
                      .child("groups/${widget.groupId}/messages")
                      .orderByChild("timestamp")
                      .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text("No messages yet."));
                }

                Map<dynamic, dynamic> messages =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Map<String, dynamic>> messageList =
                    messages.entries.map((entry) {
                      return {
                        "userId": entry.value["userId"],
                        "text": entry.value["text"],
                        "timestamp": entry.value["timestamp"],
                      };
                    }).toList();

                messageList.sort(
                  (a, b) => a["timestamp"].compareTo(b["timestamp"]),
                );

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: messageList.length,
                  itemBuilder: (context, index) {
                    final message = messageList[index];
                    final isMe =
                        message["userId"] == "Anonymous" ||
                        message["userId"].startsWith("User-");
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message["userId"],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              message["text"],
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isAnonymous ? Icons.visibility_off : Icons.visibility,
              color: Colors.red,
            ),
            onPressed: () {
              setState(() {
                isAnonymous = !isAnonymous;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}
