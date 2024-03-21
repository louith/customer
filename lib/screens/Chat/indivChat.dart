import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/form_container_widget.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Chat/chatBubble.dart';
import 'package:customer/screens/Chat/chatservices.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:badges/badges.dart' as badges;

class IndivChat extends StatefulWidget {
  String userName;
  IndivChat({super.key, required this.userName});

  @override
  State<IndivChat> createState() => _IndivChatState();
}

class _IndivChatState extends State<IndivChat> {
  final TextEditingController _messageController = TextEditingController();
  final ChatServices chatServices = ChatServices();
  String currentUsername = '';
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  final ImagePicker picker = ImagePicker();
  File? image;
  XFile? imageRef;
  bool imageAdded = false;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      try {
        await chatServices.sendMessage(
            widget.userName, _messageController.text);
      } catch (e) {
        log('Error sending message $e');
      }
      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentuserid();
  }

  getCurrentuserid() async {
    try {
      final docRef =
          _firebaseFirestore.collection('users').doc(currentUser!.uid);
      final docSnapshot = await docRef.get();
      final username = docSnapshot.data()?['Username'];
      setState(() {
        currentUsername = username;
      });
    } catch (e) {
      log('Error getting currentuser name of customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: Text(
            'Chat ${widget.userName}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        body: SafeArea(
            child: Center(
          child: Column(children: [
            Expanded(
              child: builderMessageList(),
            ),
            messageInput(),
          ]),
        )));
  }

  Widget builderMessageList() {
    return StreamBuilder(
      stream: chatServices.getMessages(widget.userName, currentUsername),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: kPrimaryColor));
        }
        return ListView(
          children: snapshot.data!.docs
              .map((document) => messageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget messageItem(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    var alignment = (data['senderId'] == currentUsername)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(data['senderId']),
          ChatBubble(message: data['messageText'])
        ],
      ),
    );
  }

  Widget messageInput() {
    return Row(
      children: [
        !imageAdded
            ? Container()
            : SizedBox.square(
                dimension: 80,
                child: badges.Badge(
                  position: badges.BadgePosition.topEnd(end: 18),
                  badgeContent: const Text(
                    '-',
                    style: TextStyle(color: Colors.white),
                  ),
                  child: Image.file(image!),
                  onTap: () {
                    setState(() {
                      imageAdded = false;
                      image = null;
                      imageRef = null;
                    });
                  },
                ),
              ),
        Expanded(
            child: TextField(
          controller: _messageController,
          decoration: const InputDecoration(hintText: 'Enter Message'),
          obscureText: false,
        )),
        IconButton(
            onPressed: attachImage,
            icon: const Icon(
              Icons.image,
              color: kPrimaryColor,
            )),
        IconButton(
            onPressed: () {
              log('sending..');
              sendImage();
              sendMessage();
            },
            icon: const Icon(
              Icons.send,
              color: kPrimaryColor,
            ))
      ],
    );
  }

  void sendImage() async {
    if (!imageAdded && image.toString().isEmpty) {
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference dirImages =
          referenceRoot.child('chatImages').child(currentUser!.uid);
      await dirImages.putFile(image!);
      String imageUrl = await dirImages.getDownloadURL();
      chatServices.sendMessage(widget.userName, imageUrl).then((value) {
        setState(() {
          imageAdded = false;
          image = null;
          imageRef = null;
        });
      });
    }
  }

  Future<dynamic> attachImage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            title: const Text(
              "Select Image From",
              style: TextStyle(fontSize: 16),
            ),
            content: SizedBox.square(
              dimension: 80,
              // height: MediaQuery.of(context).size.height * .20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      imageRef =
                          await picker.pickImage(source: ImageSource.camera);
                      try {
                        setState(() {
                          image = File(imageRef!.path);
                          imageAdded = true;
                        });
                        log(image.toString());
                      } catch (e) {
                        log('???');
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded),
                            Text('Camera')
                          ],
                        )),
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      imageRef =
                          await picker.pickImage(source: ImageSource.gallery);
                      try {
                        setState(() {
                          image = File(imageRef!.path);
                          imageAdded = true;
                        });
                        log(image.toString());
                      } catch (e) {
                        log('???');
                      }
                    },
                    child: Container(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.image), Text('Gallery')],
                        )),
                  ),
                ],
              ),
            ));
      },
    );
  }
}
