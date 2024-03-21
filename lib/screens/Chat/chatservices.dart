import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String> getCurrentuserid() async {
    try {
      final docRef =
          _firebaseFirestore.collection('users').doc(currentUser!.uid);
      final docSnapshot = await docRef.get();
      final username = docSnapshot.data()?['Username'];
      return username;
    } catch (e) {
      log('Error getting currentuser name: $e');
      return '';
    }
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      messageText: message,
      senderId: await getCurrentuserid(),
      receiverId: receiverId,
      timestamp: timestamp,
    );

    List<String> ids = [await getCurrentuserid(), receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      await _firebaseFirestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .set({'ref': ''});
      await _firebaseFirestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .add(newMessage.toMap());
    } catch (e) {
      log('error sending message $e');
    }
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
