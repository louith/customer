// ignore_for_file: must_be_immutable
import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Booking/approve_appointment.dart';
import 'package:flutter/material.dart';
import 'package:customer/models/service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  String clientID;
  String clientUsername;
  String customerUsername;
  Map<String, ClientService> cart;
  String address;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  String role;

  PaymentScreen({
    super.key,
    required this.clientUsername,
    required this.clientID,
    required this.customerUsername,
    required this.cart,
    required this.address,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    required this.role,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late String serviceFee;
  List<int> prices = [];

  @override
  void initState() {
    super.initState();
    widget.cart.forEach((key, value) {
      prices.add(int.parse(value.price));
    });
    serviceFee = (prices.reduce((value, element) => value + element) * 0.05)
        .toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Select Payment Method',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor),
            ),
            ListTile(
              title: const Text('Cash'),
              onTap: () {
                approveAppointment(
                    'Cash',
                    ApproveAppointment(
                      serviceFee: serviceFee,
                      clientUsername: widget.clientUsername,
                      clientID: widget.clientID,
                      customerUsername: widget.customerUsername,
                      cart: widget.cart,
                      address: widget.address,
                      dateTimeFrom: widget.dateTimeFrom,
                      dateTimeTo: widget.dateTimeTo,
                      paymentMethod: 'Cash',
                      role: widget.role,
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }

  approveAppointment(String paymentMethod, dynamic screen) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return screen;
      },
    ));
  }

  String formatDouble(double value) {
    final format = NumberFormat('#,##0.00');
    return format.format(value);
  }

  Future<dynamic> gcashPayment(List<ClientService> cart) async {
    final amount =
        cart.fold(0, (previousValue, element) => int.parse(element.price));
    return amount;
  }
}

class PayCard extends StatelessWidget {
  PayCard({super.key});

  final CardFormEditController cardFormEditController =
      CardFormEditController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
          child: Container(
        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Pay with Card',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor),
            ),
            const SizedBox(height: defaultPadding),
            const Row(
              children: [
                Text(
                  'Card Form',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            CardFormField(
              controller: cardFormEditController,
            ),
            const SizedBox(height: defaultPadding),
            ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Pay',
                  style: TextStyle(color: kPrimaryLightColor),
                )),
          ],
        ),
      )),
    );
  }
}
