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
import 'package:simple_accordion/simple_accordion.dart';

class Rating extends StatefulWidget {
  final String reference;
  // final Transactions transactions;
  Rating({super.key, required this.reference});

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _comment = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<List<dynamic>> getServiceRating() async {
    List<dynamic> services = [];
    DocumentSnapshot booking = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('bookings')
        .doc(widget.reference)
        .get();

    services.addAll(booking.get('services'));
    return services;
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
      padding: EdgeInsets.only(top: 45),
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
            child: Container(
              child: Column(children: [
                Row(
                  children: [
                    Text(
                      'Services: ',
                      style: TextStyle(fontSize: 16),
                    ),
                    FutureBuilder<List<dynamic>>(
                        future: getServiceRating(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Text(
                                'loading Review button...',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: grayText,
                                    fontSize: 12),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<dynamic> items = snapshot.data!;

                            return ListView.builder(
                                itemCount: items.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return SubCategoriesRow(
                                      itemList: items[index]['serviceName']);
                                });
                          }
                        })

                    // ListView.builder(
                    // itemCount: widget.transactions.services.length,
                    // scrollDirection: Axis.vertical,
                    // itemBuilder: (context, index) {
                    // final item = widget.transactions.services[index];
                    // return Text(widget.transactions.services[index]
                    // ['serviceName']);
                    // return Container(
                    // padding: const EdgeInsets.symmetric(
                    // horizontal: 6, vertical: 1),
                    // decoration: BoxDecoration(
                    // color: Colors.purple[100],
                    // borderRadius: BorderRadius.circular(100)),
                    // child: Text(
                    // widget.transactions.services[index]
                    // ['serviceName'],
                    // style: TextStyle(fontSize: 16),
                    // ),
                    // );
                    // })
                  ],
                ),
                SizedBox(
                  height: defaultformspacing,
                ),
                Row(children: [
                  Text(
                    'Rating:',
                    style: TextStyle(fontSize: 16),
                  ),
                  RatingBar.builder(
                      initialRating: 1,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      }),
                ]),
                SizedBox(
                  height: defaultformspacing,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'Comment:',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextFormField(
                      maxLines: 4,
                      controller: _comment,
                      decoration: InputDecoration(
                        hintText: 'Comment',
                      )),
                ]),
                SizedBox(
                  height: defaultformspacing,
                ),
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
                  child: Text('Upload Pictures'),
                ),
                nextButton(context, () {}, 'SUBMIT RATING')
              ]),
            ),
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
