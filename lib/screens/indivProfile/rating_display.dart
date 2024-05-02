import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:customer/screens/FreelancerCategoryScreens/Hair.dart';
import 'package:flutter/material.dart';
import 'package:customer/components/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

class RatingCard {
  String currCustId;
  String custName;
  String comment;
  String timestamp;
  List<String> services;
  double starRating;

  RatingCard(
      {required this.currCustId,
      required this.comment,
      required this.custName,
      required this.services,
      required this.starRating,
      required this.timestamp});

  // String get formattedTimestamp {
  // final dateTime = timestamp.toDate();
  // Format the timestamp as desired (e.g., using DateFormat)
  // return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  // }
}

class RatingDisplay extends StatefulWidget {
  final String clientId;
  final String role;
  final double averageRating;
  const RatingDisplay(
      {super.key,
      required this.clientId,
      required this.role,
      required this.averageRating});

  @override
  State<RatingDisplay> createState() => _RatingDisplayState();
}

class _RatingDisplayState extends State<RatingDisplay> {
  Future<List<String>> getBookingIds() async {
    List<String> bookingIds = [];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientId)
        .collection('bookings')
        .where('status', isEqualTo: 'finished')
        .get()
        .then((snapshot) => snapshot.docs.forEach((element) {
              bookingIds.add(element.reference.id.toString());
            }));
    // print(bookingIds as List<String>);
    return bookingIds;
  }

  // Future<bool> ifRatingsCollectionExists() async {
  // bool ratingsColExist = false;
  // final QuerySnapshot<Map<String, dynamic>> ratingsCol =
  // await FirebaseFirestore.instance
  // .collection('users')
  // .doc(widget.clientId)
  // .collection('bookings')
  // .doc('I6bvF41NkYm443yymgGk')
  // .collection('ratings')
  // .get();
//
  // if (ratingsCol.docs.isEmpty) {
  // setState(() {
  // ratingsColExist = false;
  // });
  // } else {
  // setState(() {
  // ratingsColExist = true;
  // });
  // ;
  // }
//
  // return ratingsColExist;
  // }

  Future<RatingCard?> getEachRating(String bookingId) async {
    final DocumentSnapshot<Map<String, dynamic>> bookingDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.clientId)
            .collection('bookings')
            .doc(bookingId)
            .get();

    if (!bookingDoc.data()!.containsKey('rating')) {
      return null;
    }

    Map<String, dynamic> rating = bookingDoc.get('rating');

    return RatingCard(
        currCustId: rating['currentUser'],
        comment: rating['comment'],
        custName: rating['custName'],
        services: rating['services'],
        starRating: double.parse(rating['rating']),
        timestamp: rating['timestamp']);

    // .doc('rating')
    // .get();

    // if (!ratingG.exists) {
    // return null;
    // }

    // final DocumentSnapshot ratingDoc = await FirebaseFirestore.instance
    // .collection('users')
    // .doc(widget.clientId)
    // .collection('bookings')
    // .doc(bookingId)
    // .collection('ratings')
    // .doc('rating')
    // .get();

    // Map<String, dynamic> rating = ratingDoc.data() as Map<String, dynamic>;

    // return RatingCard(
    // currCustId: rating['currentUser'],
    // comment: rating['comment'],
    // custName: rating['custName'],
    // services: rating['services'],
    // starRating: double.parse(rating['rating']), //double
    // timestamp: rating['timestamp'].toString(), //timestamp parsed to string
    // );
  }

  Future<List<RatingCard>> getRatingsList() async {
    List<Future<RatingCard?>> futures = [];

    for (var bookingId in (await getBookingIds())) {
      futures.add(getEachRating(bookingId));
    }

    List<RatingCard?> ratingCardsWithNull =
        await Future.wait<RatingCard?>(futures);
    print(ratingCardsWithNull as List<RatingCard>);
    return ratingCardsWithNull.whereType<RatingCard>().toList();
  }

  Stream<List<RatingCard>> getRatingCardStream() {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientId)
        .collection('bookings');
    return collectionRef.snapshots().map((querySnapshot) {
      final ratingCards = <RatingCard>[];
      for (final documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          if (documentSnapshot.data().containsKey('rating')) {
            final mapValue = documentSnapshot.data()['rating'];
            if (mapValue is Map<String, dynamic>) {
              try {
                final timestamp = mapValue['timestamp'] as Timestamp;
                final formattedTimestamp = timestamp.toDate().toString();
                final ratingCard = RatingCard(
                  currCustId: mapValue['currentUser'],
                  custName: mapValue['custName'],
                  comment: mapValue['comment'],
                  services: mapValue['services'].cast<String>(),
                  starRating: mapValue['rating'].toDouble(),
                  timestamp: formattedTimestamp,
                );
                ratingCards.add(ratingCard);
              } catch (e) {
                // Handle potential errors during RatingCard creation (print or throw)
                print(
                    'Error creating RatingCard from document ${documentSnapshot.id}: $e');
              }
            } else {
              // Handle case where field exists but isn't a map (optional)
              print(
                  'Field "rating" in document ${documentSnapshot.id} is not a map.');
            }
          }
        }
      }
      return ratingCards;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Customer Ratings',
            style: TextStyle(color: kPrimaryLightColor),
          ),
        ),
        body: StreamBuilder<List<RatingCard>>(
            stream: getRatingCardStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('walay ratings'),
                );
              } else {
                List<RatingCard> ratingsList = snapshot.data!;
                return ListView.builder(
                    itemCount: ratingsList.length,
                    itemBuilder: (context, index) {
                      return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 18, horizontal: defaultPadding),
                          margin: EdgeInsets.fromLTRB(
                              defaultPadding, 0, defaultPadding, 0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey, // Change color as desired
                                  width: 0.5, // Set border width
                                ),
                              )),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      ratingsList[index].custName.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      ratingsList[index].timestamp,
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    )
                                  ],
                                ),
                                SizedBox(height: 4),
                                SubCategoriesRow(
                                    itemList: ratingsList[index].services),
                                SizedBox(height: 4),
                                RatingBar.builder(
                                  allowHalfRating: true,
                                  ignoreGestures: true,
                                  initialRating: ratingsList[index].starRating,
                                  maxRating: 5,
                                  minRating: 0,
                                  itemSize: 18,
                                  direction: Axis.horizontal,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (value) => {},
                                ),
                                SizedBox(height: 8),
                                Text(ratingsList[index].comment)
                              ]));
                    });
              }
            }),
      ),
    );
  }


  Future<List> getRatingsServices() async {
    try {
      List<String> ids = [];
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientId)
          .collection('bookings')
          .where('status', isEqualTo: 'finished')
          .get();
      querySnapshot.docs.forEach((element) {
        ids.add(element.id);
      });
      log("$ids");

  // Future<List> getRatingsServices() async {
  // try {
  // List<String> ids = [];
  // QuerySnapshot querySnapshot = await db
  // .collection('users')
  // .doc(widget.clientId)
  // .collection('bookings')
  // .where('status', isEqualTo: 'finished')
  // .get();
  // querySnapshot.docs.forEach((element) {
  // ids.add(element.id);
  // });
  // log("$ids");

  // return ids;
  // } catch (e) {
  // log('error getting service ratings $e');
  // return [];
  // }
  // }
}
