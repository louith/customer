import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Hair.dart';
import 'package:customer/screens/Homescreen/booking_transcations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class Rating extends StatefulWidget {
  final String clientId;
  Transactions transactions;
  final String reference;
  // final Transactions transactions;
  Rating({
    super.key,
    required this.reference,
    required this.clientId,
    required this.transactions,
  });

  @override
  State<Rating> createState() => _RatingState();
}

class _RatingState extends State<Rating> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _comment = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _rating = 0.0;
  String _imgUrl = "";

  Future<List<dynamic>> getServiceRating() async {
    List<dynamic> servicesZ = [];
    DocumentSnapshot booking = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('bookings')
        .doc(widget.reference)
        .get();

    var services = booking.get('services');
    servicesZ.addAll(services);

    print(servicesZ as List<dynamic>);
    return servicesZ;
  }

  // File? image;
  // UploadTask? uploadTask;
  // Future pickImage(ImageSource source) async {
  // try {
  // final image = await ImagePicker().pickImage(source: source);
  // if (image == null) return;
  // final imageTemporary = File(image.path);
  // this.image = imageTemporary;
  // setState(() {
  // this.image = imageTemporary;
  // });
  // } on PlatformException catch (e) {
  // print('Failed to pick image: ${e}');
  // }
  // }

  // Future<String> uploadProfPic() async {
  // final Reference path = FirebaseStorage.instance.ref('ratings/');
  // final File file = File(image!.path);
  // final Reference customerProfile =
  // path.child(currentUser!.uid).child('image.jpg');
  // await customerProfile.putFile(file);
  // String urlDownload = await customerProfile.getDownloadURL();
  // return urlDownload;
  // }

  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> addRatingToFirestore(Map<String, dynamic> data) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('bookings')
        .doc(widget.reference)
        .collection('ratings')
        .doc('rating');

    final worker_salonRef = firestore
        .collection('users')
        .doc(widget.clientId)
        .collection('bookings')
        .doc(widget.reference)
        .collection('ratings')
        .doc('rating');

    // Add a new document with auto-generated ID
    try {
      await collectionRef.set(data);
      await worker_salonRef.set(data);
      print("Data added to collection: rating");
    } on FirebaseException catch (error) {
      print("Error adding data: ${error.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> _services = [];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            height: screenHeight,
            width: screenWidth,
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Services: ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    width: screenWidth,
                    height: 25,
                    margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: FutureBuilder<List<dynamic>>(
                        future: getServiceRating(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                                child: Text(
                              'Loading service...',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ));
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<dynamic> services = snapshot.data!;
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ListView.builder(
                                itemCount: services.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  _services.add(services[index]['serviceName']);
                                  return Container(
                                      margin: EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                          color: kPrimaryLightColor,
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 8),
                                      child:
                                          Text(services[index]['serviceName']));
                                },
                              ),
                            );
                          }
                        }),
                  )
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
                    itemSize: 50,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                    onRatingUpdate: (rating) =>
                        setState(() => _rating = rating)),
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
                      hintText: 'The worker did a good job...',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Share your experiences!';
                      }
                    }),
              ]),
              SizedBox(
                height: defaultformspacing,
              ),
              // Row(
              // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              // children: [
              // TextButton.icon(
              // onPressed: () async {
              // ImagePicker imagePicker = ImagePicker();
              // XFile? file = await imagePicker.pickImage(
              // source: ImageSource.gallery);
              // print('Path: ${file?.path}');

              // if (file == null) return;
              // Reference referenceRoot =
              // FirebaseStorage.instance.ref();
              // Reference referenceDirImages = referenceRoot
              // .child('ratings')
              // .child(currentUser!.uid)
              // .child(widget.reference);
              // Reference refImgToUpload =
              // referenceDirImages.child('ratingImg');

              // try {
              // await refImgToUpload.putFile(File(file.path));
              // _imgUrl = await refImgToUpload.getDownloadURL();
              // } catch (e) {
              // print('Error occured $e');
              // }
              // },
              // icon: const Icon(Icons.image_outlined),
              // label: const Text('Pick from Gallery')),
              // TextButton.icon(
              // onPressed: () async {
              // ImagePicker imagePicker = ImagePicker();
              // XFile? file = await imagePicker.pickImage(
              // source: ImageSource.camera);
              // print('${file?.path}');
              // if (file == null) return;
              // String uniqueFileName = widget.reference + 'ratingImg';
              // Reference referenceRoot =
              // FirebaseStorage.instance.ref();
              // Reference referenceDirImages =
              // referenceRoot.child('ratings');
              // Reference folderId =
              // referenceDirImages.child(currentUser!.uid);
              // Reference refImgToUpload =
              // folderId.child(uniqueFileName);
              // try {
              // await refImgToUpload.putFile(File(file.path));
              // var imageUrl = await refImgToUpload.getDownloadURL();
              // } catch (e) {
              // print('Error occured $e');
              // }
              // },
              // icon: const Icon(Icons.camera_outlined),
              // label: const Text('Pick from Camera')),
              // ],
              // ),
              // const SizedBox(
              // height: defaultformspacing,
              // ),
              nextButton(context, () async {
                DocumentSnapshot<Map<String, dynamic>> userInfo =
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .get();

                String username = userInfo.data()!['Username'];
                Map<String, dynamic> userData = {
                  "services": _services,
                  "comment": _comment.text,
                  "rating": _rating,
                  "timestamp": DateTime.now(),
                  "currentUser": currentUser!.uid,
                  "clientId": widget.clientId,
                  "custName": username
                };

                addRatingToFirestore(userData);
                Navigator.pop(context);
                toastification.show(
                    type: ToastificationType.success,
                    context: context,
                    icon: Icon(Icons.rate_review),
                    title: Text('Rating saved!'),
                    autoCloseDuration: const Duration(seconds: 3),
                    showProgressBar: false,
                    alignment: Alignment.topCenter,
                    style: ToastificationStyle.fillColored);
              }, 'SUBMIT RATING')
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> sendFeedback() async {
    String clientUid = '';
    DocumentSnapshot documentSnapshot =
        await db.collection('users').doc(currentUser!.uid).get();
    String customerUsername = documentSnapshot['Username'];
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .where('name', isEqualTo: widget.transactions.clientUsername)
        .get();
    querySnapshot.docs.forEach((element) {
      clientUid = element.id;
    });
    await db.collection('users').doc(clientUid).collection('ratings').add({
      'rating': ratingValue,
      'customer': customerUsername,
      'comment': _comment.text,
    });
    if (mounted) {
      Navigator.pop(context);
    }
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
