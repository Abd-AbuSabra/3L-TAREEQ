import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiPage extends StatefulWidget {
  const GeminiPage({super.key});

  @override
  State<GeminiPage> createState() => _GeminiPageState();
}

class _GeminiPageState extends State<GeminiPage> {
  final Gemini gemini = Gemini.instance;

  final ChatUser _currentUser = ChatUser(
    id: "1",
    firstName: "You",
  );

  final ChatUser _geminiUser = ChatUser(
    id: "2",
    firstName: "Chat",
    lastName: "Bot",
    profileImage: 'lib/images/logo2.png',
  );

  List<ChatMessage> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DashChat(
        messageOptions: const MessageOptions(
          currentUserContainerColor: Color.fromARGB(255, 192, 228, 194),
          containerColor: Color.fromARGB(255, 233, 233, 233),
          textColor: Color.fromARGB(255, 79, 78, 78),
          borderRadius: 10,
          messagePadding: EdgeInsets.all(15),
        ),
        currentUser: _currentUser,
        onSend: _handleSend,
        messages: _messages,
      ),
    );
  }

  void _handleSend(ChatMessage message) {
    setState(() {
      _messages.insert(0, message);
    });

    final question = message.text;

    gemini.streamGenerateContent(question).listen((event) {
      final response = event.content?.parts
              ?.whereType<TextPart>()
              .map((part) => part.text)
              .join(" ") ??
          "";

      final botMessage = ChatMessage(
        user: _geminiUser,
        createdAt: DateTime.now(),
        text: response.trim(),
      );

      setState(() {
        _messages.insert(0, botMessage);
      });
    });
  }
}