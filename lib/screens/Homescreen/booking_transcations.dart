import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/transaction_history.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Transactions {
  String clientUsername;
  DateTime dateFrom;
  DateTime dateTo;
  String location;
  String paymentMethod;
  String reference;
  String status;
  String total;
  String serviceFee;
  List<dynamic> services;
  String? preferredWorker;
  String? reason;
  String customerUid;

  Transactions({
    required this.clientUsername,
    required this.dateFrom,
    required this.dateTo,
    required this.location,
    required this.paymentMethod,
    required this.reference,
    required this.status,
    required this.services,
    required this.serviceFee,
    required this.total,
    required this.customerUid,
    this.preferredWorker,
    this.reason,
  });
}

class BookingTransactions extends StatefulWidget {
  String customerUid;
  BookingTransactions({
    super.key,
    required this.customerUid,
  });

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
          .doc(widget.customerUid)
          .collection('bookings')
          .get();
      querySnapshot.docs.forEach((doc) {
        String? reason;
        String? worker;
        if ((doc.data() as Map<String, dynamic>).containsKey('reason')) {
          reason = doc['reason'];
        }
        if ((doc.data() as Map<String, dynamic>).containsKey('worker')) {
          worker = doc['worker'];
        }

        // String? worker = doc['worker'];
        //add required fields
        transactionsList.add(Transactions(
          serviceFee: doc['serviceFee'],
          total: doc['totalAmount'],
          clientUsername: doc['clientUsername'],
          dateFrom: doc['dateFrom'].toDate(),
          dateTo: doc['dateTo'].toDate(),
          location: doc['location'],
          paymentMethod: doc['paymentMethod'],
          reference: doc['reference'],
          status: doc['status'],
          services: doc['services'],
          customerUid: widget.customerUid,
          preferredWorker: worker,
          reason: reason,
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
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: const Text(
            'Booking Transactions',
            style: TextStyle(color: kPrimaryLightColor),
          ),
        ),
        body: Background(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
            child: FutureBuilder(
              future: getBookingTransactions(),
              builder: (context, transactions) {
                if (transactions.hasData) {
                  final data = transactions.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: transactions.data!.length,
                    itemBuilder: (context, index) {
                      Color statusColor = data[index].status.toLowerCase() ==
                              'pending'
                          ? Colors.grey
                          : data[index].status.toLowerCase() == 'confirmed'
                              ? Colors.green
                              : data[index].status.toLowerCase() == 'complete'
                                  ? kPrimaryColor
                                  : data[index].status.toLowerCase() == 'denied'
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
                                        data[index].clientUsername,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      //date from and date to of appointment
                                      Text(
                                          ' - ${DateFormat.MMMEd().format(data[index].dateFrom)}'),
                                    ],
                                  ),
                                  //status
                                ],
                              ),
                              const SizedBox(height: defaultPadding),
                              Text(data[index].location), //address
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    data[index].status.toUpperCase(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: statusColor),
                                  ),
                                ],
                              )
                            ],
                          ),
                          TransactionHistory(transactions: data[index]));
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget transaction(Widget child, dynamic page) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return page;
          },
        ));
      },
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
