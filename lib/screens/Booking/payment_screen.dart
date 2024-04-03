import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/screens/Booking/approve_appointment.dart';
import 'package:flutter/material.dart';
import 'package:customer/models/service.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  String clientID;
  String clientUsername;
  String customerUsername;
  Map<String, ClientService> cart;
  String address;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;

  PaymentScreen({
    super.key,
    required this.clientUsername,
    required this.clientID,
    required this.customerUsername,
    required this.cart,
    required this.address,
    required this.dateTimeFrom,
    required this.dateTimeTo,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
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
              title: const Text('GCash'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Cash'),
              onTap: approveAppointment,
            ),
          ],
        ),
      ),
    );
  }

  approveAppointment() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return ApproveAppointment(
          clientUsername: widget.clientUsername,
          clientID: widget.clientID,
          customerUsername: widget.customerUsername,
          cart: widget.cart,
          address: widget.address,
          dateTimeFrom: widget.dateTimeFrom,
          dateTimeTo: widget.dateTimeTo,
          paymentMethod: 'Payment Method',
        );
      },
    ));
  }

  String formatDouble(double value) {
    final format = NumberFormat('#,##0.00');
    return format.format(value);
  }

  Future<void> gcashPayment(List<ClientService> cart) async {
    final amount =
        cart.fold(0, (previousValue, element) => int.parse(element.price));
  }
}
