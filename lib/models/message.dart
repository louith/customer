import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String messageText;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.timestamp,
  });
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'messageText': messageText,
    };
  }
}
