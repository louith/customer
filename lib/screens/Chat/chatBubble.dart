import 'package:customer/components/constants.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: kPrimaryLightColor,
        ),
        child: message.substring(0, 4) != "http"
            ? Text(
                message,
                style: const TextStyle(fontSize: 16),
              )
            : InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Image.network(message),
                      );
                    },
                  );
                },
                child: Image.network(
                  message,
                  height: 100,
                ),
              ));
  }
}
