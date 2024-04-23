import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/form_container_widget.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Hair.dart';
import 'package:customer/screens/Homescreen/booking_transcations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';

class Rating extends StatefulWidget {
  Transactions transactions;
  final String reference;
  // final Transactions transactions;
  Rating({
    super.key,
    required this.reference,
    required this.transactions,
  });

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _comment = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double ratingValue = 1;

  Future<List<dynamic>> getServiceRating() async {
    try {
      List<dynamic> services = [];
      DocumentSnapshot booking = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('bookings')
          .doc(widget.reference)
          .get();

      services.addAll(booking.get('services'));
      log(services.toString());
      return services;
    } catch (e) {
      log('error rating $e');
      return [];
    }
  }

  File? image;
  UploadTask? uploadTask;
  Future pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      final imageTemporary = File(image.path);
      this.image = imageTemporary;
      setState(() {
        this.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: ${e}');
    }
  }

  Future<String> uploadProfPic() async {
    final Reference path = FirebaseStorage.instance.ref('ratings/');
    final File file = File(image!.path);
    final Reference customerProfile =
        path.child(currentUser!.uid).child('image.jpg');
    await customerProfile.putFile(file);
    String urlDownload = await customerProfile.getDownloadURL();
    return urlDownload;
  }

  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: const Text('Rating'),
          automaticallyImplyLeading: true,
        ),
        body: Background(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              const SizedBox(height: defaultformspacing),
              Row(children: [
                const Text(
                  'Rating:',
                  style: TextStyle(fontSize: 16),
                ),
                RatingBar.builder(
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingValue = rating;
                    });
                  },
                  initialRating: ratingValue,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                ),
              ]),
              const SizedBox(height: defaultformspacing),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(
                  'Comment:',
                  style: TextStyle(fontSize: 16),
                ),
                TextFormField(
                    maxLines: 4,
                    controller: _comment,
                    decoration: const InputDecoration(
                      hintText: 'Comment',
                    )),
              ]),
              const SizedBox(height: defaultformspacing),
              Row(
                children: [
                  TextButton.icon(
                      onPressed: () => pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined),
                      label: const Text('Pick from Gallery')),
                  TextButton.icon(
                      onPressed: () => pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_outlined),
                      label: const Text('Pick from Camera')),
                ],
              ),
              const SizedBox(
                height: defaultformspacing,
              ),
              TextButton(
                onPressed: uploadProfPic,
                child: const Text('Upload Pictures'),
              ),
              nextButton(context, () async {
                String clientUid = '';
                DocumentSnapshot documentSnapshot =
                    await db.collection('users').doc(currentUser!.uid).get();
                String customerUsername = documentSnapshot['Username'];
                QuerySnapshot querySnapshot = await db
                    .collection('users')
                    .where('name',
                        isEqualTo: widget.transactions.clientUsername)
                    .get();
                querySnapshot.docs.forEach((element) {
                  clientUid = element.id;
                });
                await db
                    .collection('users')
                    .doc(clientUid)
                    .collection('ratings')
                    .add({
                  'rating': ratingValue,
                  'customer': customerUsername,
                  'comment': _comment.text,
                });
                if (mounted) {
                  Navigator.pop(context);
                }
              }, 'SUBMIT RATING')
            ]),
          ),
        ),
      ),
    );
  }
}


//  SizedBox(
//  height: defaultformspacing,
//  ),
//  Row(children: [
//  Text(
//  'Rating:',
//  style: TextStyle(fontSize: 16),
//  ),
//  RatingBar.builder(
//  initialRating: 1,
//  minRating: 1,
//  direction: Axis.horizontal,
//  allowHalfRating: true,
//  itemCount: 5,
//  itemSize: 20,
//  itemPadding:
//  EdgeInsets.symmetric(horizontal: 4.0),
//  itemBuilder: (context, _) => Icon(
//  Icons.star,
//  color: Colors.amber,
//  ),
//  onRatingUpdate: (rating) {
//  print(rating);
//  }),
//  ]),
//  SizedBox(
//  height: defaultformspacing,
//  ),
//  Column(
//  crossAxisAlignment: CrossAxisAlignment.start,
//  mainAxisAlignment: MainAxisAlignment.center,
//  children: [
//  Text('Comment:',
//  style: TextStyle(fontSize: 16)),
//  FormContainerWidget(
//  icon: Icons.comment,
//  controller: _comment,
//  )
//  ])
