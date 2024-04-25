import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:flutter/material.dart';
import 'package:customer/components/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRatingsServices();
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
        // body: StreamBuilder<List<RatingCard>>(
        //     stream: Stream.fromFuture(getRatingsList()),
        //     builder: (context, snapshot) {
        //       if (!snapshot.hasData) {
        //         return const Center(
        //           child: Text('walay ratings'),
        //         );
        //       } else {
        //         List<RatingCard> ratingsList = snapshot.data!;
        //         return ListView.builder(
        //             itemCount: ratingsList.length,
        //             itemBuilder: (context, index) {
        //               return ListTile(
        //                 title: Text('tangina mo'),
        //               );
        //             });
        //       }
        //     }),
      ),
    );
  }

  Future<List> getRatingsServices() async {
    try {
      List<String> ids = [];
      QuerySnapshot querySnapshot = await db
          .collection('users')
          .doc(widget.clientId)
          .collection('bookings')
          .where('status', isEqualTo: 'finished')
          .get();
      querySnapshot.docs.forEach((element) {
        ids.add(element.id);
      });
      log("$ids");

      return ids;
    } catch (e) {
      log('error getting service ratings $e');
      return [];
    }
  }
}
