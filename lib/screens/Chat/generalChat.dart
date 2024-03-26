import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Chat/indivChat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GeneralChatPage extends StatefulWidget {
  const GeneralChatPage({super.key});

  @override
  State<GeneralChatPage> createState() => _GeneralChatPageState();
}

class _GeneralChatPageState extends State<GeneralChatPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username = '';
  Stream<List<String>>? userChatList;

  @override
  void initState() {
    getUsername();
    getChatDocuments();
    super.initState();
    userChatList = getChatDocuments().asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text(
          'General Chat Page',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
      ),
      body: Background(
          child: Container(
        child: usersChatList(),
      )),
    );
  }

  Widget usersChatList() {
    return StreamBuilder(
      stream: userChatList,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error getting chat items ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor));
        }
        final chatList = snapshot.data!;
        return ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            final chat = getChatName(chatList[index]);
            return ListTile(
              title: Text(chat),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return IndivChat(userName: chat);
                  },
                ));
              },
            );
          },
        );
      },
    );
  }

  String getChatName(String chatRoom) {
    List<String> parts = chatRoom.split("_");

    if (parts[0] == username) {
      return parts[1];
    } else if (parts[1] == username) {
      return parts[0];
    } else {
      log("Current username not found in chatroom name");
      return '';
    }
  }

  getUsername() async {
    try {
      final docRef =
          await firestore.collection('users').doc(currentUser!.uid).get();
      final getUsername = docRef.data()?['Username'];
      setState(() {
        username = getUsername;
      });
    } catch (e) {
      log('error getting username $e');
    }
  }

  Future<List<String>> getChatDocuments() async {
    List<String> documents = [];
    try {
      final querySnapshot = await firestore.collection('chat_rooms').get();
      for (final doc in querySnapshot.docs) {
        if (doc.id.contains(username)) {
          documents.add(doc.id);
        }
      }
      return documents;
    } catch (e) {
      log('error getting chat documents: $e');
      return [];
    }
  }
}
