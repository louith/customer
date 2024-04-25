import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Homescreen/cashin_screen.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class WalletDetails extends StatefulWidget {
  Profile profile;

  WalletDetails({
    super.key,
    required this.profile,
  });

  @override
  State<WalletDetails> createState() => _WalletDetailsState();
}

User? currentUser = FirebaseAuth.instance.currentUser;

class _WalletDetailsState extends State<WalletDetails> {
  final DateFormat dateFormat = DateFormat.yMd().add_Hm();
  final amountFormat = NumberFormat('#,##0.00');
  TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StreamBuilder<num>(
                          stream: Stream.fromFuture(computeBalance()),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                '₱ ${amountFormat.format(snapshot.data)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              );
                            } else {
                              return const Text(
                                '₱ LOADING',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 18),
                              );
                            }
                          }),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CashInScreen(
                                    profile: widget.profile,
                                  ),
                                ));
                          },
                          child: const Row(
                            children: [Text('Cash In'), Icon(Icons.add)],
                          ))
                    ],
                  ),
                ],
              ),
            )),
      ),
      body: Background(
          child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: defaultPadding),
            const Text(
              'Transaction History',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: FutureBuilder(
                future: getTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final transaction = snapshot.data!;
                    if (snapshot.data!.isEmpty) {
                      return const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Empty'),
                        ],
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return transactionCard(transaction, index);
                          },
                        ),
                      );
                    }
                  } else {
                    return const Text('loading');
                  }
                },
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget transactionCard(List<Transaction> transaction, int index) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      decoration: const BoxDecoration(
        color: kPrimaryLightColor,
      ),
      child: RowDetails([
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₱ ${amountFormat.format(transaction[index].amount)}'),
            Text(dateFormat.format(transaction[index].timestamp))
          ],
        ),
        Text(
          transaction[index].description.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      List<Transaction> transactions = [];
      QuerySnapshot querySnapshot = await db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('transaction')
          .get();
      querySnapshot.docs.forEach((doc) {
        transactions.add(Transaction(
          amount: doc['amount'],
          description: doc['description'],
          timestamp: doc['timestamp'].toDate(),
        ));
      });
      return transactions;
    } catch (e) {
      log('error getting transactions history $e');
      return [];
    }
  }
}

class Transaction {
  num amount;
  String description;
  DateTime timestamp;

  Transaction({
    required this.amount,
    required this.description,
    required this.timestamp,
  });
}

Future<num> computeBalance() async {
  try {
    List<num> values = [];
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .doc(currentUser!.uid)
        .collection('transaction')
        .get();
    querySnapshot.docs.forEach((element) {
      values.add(element['amount']);
    });
    num balance = values.reduce((value, element) => value + element);
    return balance;
  } catch (e) {
    log('error computing balance $e');
    return 0;
  }
}
