import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transactions {
  String clientID;
  DateTime dateFrom;
  DateTime dateTo;
  String location;
  String paymentMethod;
  String reference;
  String status;
  List<dynamic> services;
  String? preferredWorker;

  Transactions({
    required this.clientID,
    required this.dateFrom,
    required this.dateTo,
    required this.location,
    required this.paymentMethod,
    required this.reference,
    required this.status,
    required this.services,
    this.preferredWorker,
  });
}

class BookingTransactions extends StatefulWidget {
  const BookingTransactions({super.key});

  @override
  State<BookingTransactions> createState() => _BookingTransactionsState();
}

class _BookingTransactionsState extends State<BookingTransactions> {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<List<Transactions>> getBookingTransactions() async {
    List<Transactions> transactionsList = [];
    try {
      QuerySnapshot querySnapshot = await db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('bookings')
          .get();
      querySnapshot.docs.forEach((element) {
        transactionsList.add(Transactions(
          clientID: element['clientID'],
          dateFrom: element['dateFrom'].toDate(),
          dateTo: element['dateTo'].toDate(),
          location: element['location'],
          paymentMethod: element['paymentMethod'],
          reference: element['reference'],
          status: element['status'],
          services: element['services'],
        ));
      });
      return transactionsList;
    } catch (e) {
      log('error getting transactions $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      margin: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          leading: null,
          title: const Text(
            'Booking Transactions',
            style: TextStyle(color: kPrimaryLightColor),
          ),
        ),
        body: Background(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
            child: Column(
              children: [
                FutureBuilder(
                  future: getBookingTransactions(),
                  builder: (context, transactions) {
                    if (transactions.hasData) {
                      final data = transactions.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: transactions.data!.length,
                        itemBuilder: (context, index) {
                          Color statusColor = data[index].status == 'pending'
                              ? Colors.grey
                              : data[index].status == 'confirmed'
                                  ? Colors.green
                                  : data[index].status == 'complete'
                                      ? kPrimaryColor
                                      : data[index].status == 'denied'
                                          ? Colors.red
                                          : Colors.black;
                          return transaction(
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        //client name
                                        Text(
                                          data[index].clientID,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        //date from and date to of appointment
                                        Text(
                                            ' - ${DateFormat.MMMEd().format(data[index].dateFrom)}'),
                                      ],
                                    ),
                                    //status
                                    Text(
                                      data[index].status.toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: statusColor),
                                    )
                                  ],
                                ),
                                const SizedBox(height: defaultPadding),
                                Text(data[index].location), //address
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget transaction(Widget child) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: defaultPadding),
        decoration: const BoxDecoration(
            color: kPrimaryLightColor,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.all(defaultPadding),
        child: child,
      ),
    );
  }
}
