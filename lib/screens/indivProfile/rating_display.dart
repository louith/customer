import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RatingCard {
  String currUserId;
  String custName;
  String comment;
  String timestamp;
  List<String> services;
  double starRating;

  RatingCard(
      {required this.currUserId,
      required this.comment,
      required this.custName,
      required this.services,
      required this.starRating,
      required this.timestamp});
}

class RatingDisplay extends StatefulWidget {
  final String clientId;
  final String role;
  final String averageRating;
  const RatingDisplay(
      {super.key,
      required this.clientId,
      required this.role,
      required this.averageRating});

  @override
  State<RatingDisplay> createState() => _RatingDisplayState();
}

class _RatingDisplayState extends State<RatingDisplay> {
  Future<List<String>> getBookingId() async {
    List<String> bookingIds = [];
    QuerySnapshot bookings = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientId)
        .collection('bookings')
        .get();

    bookings.docs.forEach((element) {
      bookingIds.add(element.id);
    });

    return bookingIds;
  }

  Future<List<RatingCard>> getEachRating() async {
    List<RatingCard> ratingCards = [];
    List<String> bookingIds = await getBookingId();
    for (String id in bookingIds) {
      DocumentSnapshot rating = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.clientId)
          .collection('bookings')
          .doc(id)
          .collection('ratings')
          .doc('rating')
          .get();

      ratingCards.add(RatingCard(
        currUserId: rating.get('currentUser'),
        comment: rating.get('comment'),
        custName: rating.get('custName'),
        services: rating.get('services'),
        starRating: rating.get('rating'),
        timestamp: rating.get('timestamp'),
      ));
    }

    return ratingCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Ratings'),
      ),
      // body: StreamBuilder(
      // stream: Stream.fromFuture(getEachRating()), builder: builder),
    );
  }
}
