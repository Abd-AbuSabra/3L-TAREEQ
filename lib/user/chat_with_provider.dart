import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/components/auth_service.dart';
import 'package:flutter_application_33/user/Users_profile.dart';
import 'package:flutter_application_33/user/dashboard_user.dart';
import 'package:flutter_application_33/user/login.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverUserID;
  final String receiverEmail;

  const ChatScreen({
    Key? key,
    required this.receiverUserID,
    required this.receiverEmail,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isConfirmed = false; 


  void sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverUserID,
        _controller.text.trim(),
      );
      _controller.clear();
    }
  }

  Widget buildBubble(String text, bool isMe, String senderName, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            isMe ? 'You' : senderName,
            style: TextStyle(
              color: isMe ? Colors.blueGrey : Colors.blue[900],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFD5EDD1) : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text),
                if (isMe)
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      status,
                      style: const TextStyle(
                          fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(_getChatRoomId())
          .collection('messages')
          .orderBy('timestamp')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Something went wrong");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        for (final doc in messages) {
          final data = doc.data() as Map<String, dynamic>;
          final isReceiver = data['receiverId'] == _auth.currentUser!.uid;
          if (isReceiver && data['status'] != 'seen') {
            doc.reference.update({'status': 'seen'});
          }
        }

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final msg = messages[messages.length - 1 - index];
            final data = msg.data() as Map<String, dynamic>;
            final isMe = data['senderId'] == _auth.currentUser!.uid;
            final status = data['status'] ?? 'sent';

            return buildBubble(data['message'], isMe, data['senderEmail'], status);
          },
        );
      },
    );
  }

  /// Generate chat room ID
  String _getChatRoomId() {
    List<String> ids = [_auth.currentUser!.uid, widget.receiverUserID];
    ids.sort();
    return ids.join("_");
  }

  /// Confirm logic
  void confirmService() {
    setState(() {
      isConfirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Service confirmed!')),
    );
  }

  /// Cancel logic
  void cancelService() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var customGreen;
    return Scaffold(
      backgroundColor: Colors.white, // Figma match
      body: SafeArea(
        child: Column(
          children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Image.asset(
                'lib/images/Logo2.png',
                height: 40,
              ),
            ),

            // Chat Messages
            Expanded(child: _buildMessageList()),

            const SizedBox(height: 10),

            // Figma-style Confirm/Cancel buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isConfirmed ? null : confirmService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004E9A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Confirm Service",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: cancelService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A4A4A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  CircularMenu(
            alignment: Alignment.bottomRight,
            toggleButtonColor: customGreen,
            toggleButtonIconColor: Colors.white,
            items: [
              CircularMenuItem(
                icon: Icons.home,
                color: customGreen,
                iconColor: Colors.white,
                 onTap: () {
                 Navigator.push(
                 context,
                MaterialPageRoute(builder: (context) => const user_dashboard()),
                );
                }
                
              ),
              
              CircularMenuItem(
                icon: Icons.person,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const users_profile()),
  );
},
              ),
              CircularMenuItem(
                icon: Icons.chat,
                color: customGreen,
                iconColor: Colors.white,
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const GeminiPage())
  );
},
              ),
              CircularMenuItem(
                icon: Icons.logout,
                color: Colors.red,
                iconColor: Colors.white,
                onTap: () async {
                 await Provider.of<AuthService>(context, listen: false).signOut();

               Navigator.pushAndRemoveUntil(
               context,
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false,
               );
               },
              ),
            ],
          ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                    ),
                  ],
                  
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}