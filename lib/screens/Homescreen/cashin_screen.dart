import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Homescreen/my_profile.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:toastification/toastification.dart';

// ignore: must_be_immutable
class CashInScreen extends StatefulWidget {
  Profile profile;
  CashInScreen({super.key, required this.profile});

  @override
  State<CashInScreen> createState() => _CashInScreenState();
}

class _CashInScreenState extends State<CashInScreen> {
  final TextEditingController _amountController = TextEditingController();
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryColor,
      padding: const EdgeInsets.only(top: 45),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: kPrimaryLightColor,
          backgroundColor: kPrimaryColor,
          title: const Text('Cash In'),
        ),
        body: Background(
            child: Container(
          margin: const EdgeInsets.fromLTRB(15, 30, 15, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enter Cash-in Amount (PHP)'),
                  const SizedBox(height: defaultPadding),
                  TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.number,
                    controller: _amountController,
                    decoration: const InputDecoration(hintText: 'Amount'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
              Column(
                children: [
                  SlideAction(
                    onSubmit: () {
                      cashIn(_amountController.text);
                    },
                    borderRadius: 8,
                    elevation: 0,
                    innerColor: kPrimaryLightColor,
                    outerColor: kPrimaryColor,
                    sliderButtonIconSize: 16,
                    height: 64,
                    text: 'Slide to Pay',
                    textStyle: const TextStyle(
                        fontSize: 16, color: kPrimaryLightColor),
                  ),
                  const SizedBox(height: defaultPadding),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }

  Future<void> cashIn(String amount) async {
    try {
      Map<String, dynamic> transaction = {
        'amount': int.parse(amount),
        'description': 'deposit',
        'timestamp': DateTime.now(),
      };

      if (amount.isNotEmpty) {
        //adding transaction to customer db
        await db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('transaction')
            .add(transaction);
        //adding transaction to admin db
        await db
            .collection('users')
            .doc(adminUid) //constant admin ID in firestore
            .collection('transaction')
            .add(transaction);
      } else {
        toastification.show(
          type: ToastificationType.error,
          context: context,
          title: const Text('Invalid Cash-in Amount'),
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
      setState(() {});
    } catch (e) {
      log('error cashing in $e');
      toastification.show(
        type: ToastificationType.error,
        context: context,
        title: const Text('Invalid Cash-in Amount'),
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  }
}
