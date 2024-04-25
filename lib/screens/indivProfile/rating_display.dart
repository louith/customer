import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<RatingCard?> getEachRating(String bookingId) async {
    final DocumentSnapshot ratingG = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.clientId)
        .collection('bookings')
        .doc(bookingId)
        .collection('ratings')
        .doc('rating')
        .get();

    if (!ratingG.exists) {
      return null;
    }

    Map<String, dynamic> rating = ratingG.data() as Map<String, dynamic>;

    return RatingCard(
      currCustId: rating['currentUser'],
      comment: rating['comment'],
      custName: rating['custName'],
      services: rating['services'],
      starRating: double.parse(rating['rating']), //double
      timestamp: rating['timestamp'].toString(), //timestamp parsed to string
    );
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

  @override
  void initState() {
    // TODO: implement initState
    // print(getRatingsList() as);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: EdgeInsets.only(top: 65),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: Text(
            'Customer Ratings',
            style: TextStyle(color: kPrimaryLightColor),
          ),
          actions: [
            TextButton(onPressed: getRatingsList, child: Text('getRatingList'))
          ],
        ),
        body: StreamBuilder<List<RatingCard>>(
            stream: Stream.fromFuture(getRatingsList()),
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
                      return ListTile(
                        title: Text('tangina mo'),
                      );
                      // return Container(
                      // margin: EdgeInsets.symmetric(
                      // vertical: 8, horizontal: defaultPadding),
                      // decoration: BoxDecoration(
                      // color: Colors.white,
                      // border: Border.symmetric(
                      // horizontal: BorderSide(
                      // color:
                      // kPrimaryLightColor, // Change color as desired
                      // width: 2.0, // Set border width
                      // ),
                      // )),
                      // child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // children: [
                      // Row(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // children: [
                      // Text(ratingsList[index].custName.toString()),
                      // Text(ratingsList[index].timestamp.toString())
                      // ],
                      // ),
                      // RatingBar.builder(
                      // allowHalfRating: true,
                      // ignoreGestures: true,
                      // initialRating: ratingsList[index].starRating,
                      // maxRating: 5,
                      // minRating: 0,
                      // itemSize: 50,
                      // direction: Axis.horizontal,
                      // itemBuilder: (context, index) => const Icon(
                      // Icons.star,
                      // color: Colors.amber,
                      // ),
                      // onRatingUpdate: (value) => {},
                      // ),
                      // ],
                      // ));
                    });
              }
            }),
      ),
    );
  }
}
