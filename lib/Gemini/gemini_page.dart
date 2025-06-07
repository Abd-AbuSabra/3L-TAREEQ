import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_33/Gemini/gemini_page.dart';
import 'package:flutter_application_33/universal_components/project_logo.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_33/user/select_service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  void initState() {
    super.initState();
    _listenForAcceptedProvider();
  }

  List<ChatMessage> _messages = [];
  final _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot>? _subscription;

  void _listenForAcceptedProvider() {
    final user = _auth.currentUser;
    if (user == null) return;

    _subscription = FirebaseFirestore.instance
        .collection('acceptedProviders')
        .where('userId', isEqualTo: user.uid)
        .where('isAccepted', isEqualTo: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final providerData =
            snapshot.docs.first.data() as Map<String, dynamic>?;
        if (providerData != null && mounted) {
          _subscription?.cancel(); // prevent multiple triggers
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ServiceProviderPage(providerData: providerData),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: const Color.fromARGB(255, 144, 223, 170),
        ),
      ),
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
