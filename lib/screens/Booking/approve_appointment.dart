// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/models/service.dart';
import 'package:customer/screens/Booking/added_appointment.dart';
import 'package:customer/screens/Homescreen/MainScreen.dart';
import 'package:customer/screens/Homescreen/wallet_details.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class Staff {
  String name;
  String role;
  String contact;

  Staff({
    required this.name,
    required this.role,
    required this.contact,
  });
}

class ApproveAppointment extends StatefulWidget {
  String clientID;
  String customerUsername;
  Map<String, ClientService> cart;
  String address;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  String paymentMethod;
  String clientUsername;
  String role;
  String serviceFee;
  Customer customer;

  ApproveAppointment({
    super.key,
    required this.customer,
    required this.clientID,
    required this.clientUsername,
    required this.customerUsername,
    required this.cart,
    required this.address,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    required this.paymentMethod,
    required this.role,
    required this.serviceFee,
  });

  @override
  State<ApproveAppointment> createState() => _ApproveAppointmentState();
}

class _ApproveAppointmentState extends State<ApproveAppointment> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<ClientService> cart;
  final format = NumberFormat('#,##0.00');
  String? dropdownValue;
  String ref = '';
  List<int> prices = [];

  @override
  void initState() {
    super.initState();
    cart = widget.cart.values.toList();
    getTotal();
    log(widget.serviceFee);
  }

  @override
  Widget build(BuildContext context) {
    return Background(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: kPrimaryColor,
              ),
            ),
            const SizedBox(height: defaultPadding),
            bookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Name'),
                Text(
                  widget.customer.fullName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                const Text('Customer Username'),
                Text(
                  widget.customerUsername,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                const Text('Salon Place'),
                Text(
                  widget.address,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                const Text('Time & Date'),
                Text(
                  "${DateFormat.jm().format(widget.dateTimeFrom)} - ${DateFormat.jm().format(widget.dateTimeTo)} | ${DateFormat('MMMMd').format(widget.dateTimeTo)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                const Text('Services'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: 30,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          return ServiceCard(cart[index].serviceName);
                        },
                      ),
                    );
                  },
                ),
              ],
            )),
            const SizedBox(height: defaultPadding),
            bookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RowDetails([
                  const Text('Payment Method'),
                  Text(widget.paymentMethod),
                ]),
                RowDetails([
                  const Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('PHP ${format.format(getTotal())}',
                      style: const TextStyle(fontWeight: FontWeight.bold))
                ]),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: cart.length + 1,
                  itemBuilder: (context, index) {
                    if (index == cart.length) {
                      cart.forEach((element) {
                        prices.add(int.parse(element.price));
                      });
                      return RowDetails([
                        const Text('Service Fee'),
                        Text('PHP ${widget.serviceFee}')
                      ]);
                    } else {
                      return RowDetails([
                        Text(cart[index].serviceName),
                        Text(
                            "PHP ${format.format(double.parse(cart[index].price))}"),
                      ]);
                    }
                  },
                ),
              ],
            )),
            const SizedBox(height: defaultPadding),
            widget.role == 'salon'
                ? StreamBuilder<List<String>>(
                    stream: Stream.fromFuture(getStaffs()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data = snapshot.data!;
                        return bookingCard(DropdownButton(
                            hint: const Text('Preferred Stylist'),
                            value: dropdownValue,
                            items: data.map((e) {
                              return DropdownMenuItem<String>(
                                  value: e, child: Text(e));
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            }));
                      } else {
                        return Container();
                      }
                    },
                  )
                : Container(),
          ],
        ),
        Column(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: ElevatedButton(
                    onPressed: () async {
                      //if online payment
                      if (widget.paymentMethod.toLowerCase() ==
                          "online wallet") {
                        //check wallet if has enough balance
                        if (getTotal() > await computeBalance()) {
                          toastification.show(
                            type: ToastificationType.error,
                            context: context,
                            title: const Text('Not enough balace'),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                        } else {
                          await addBookingWithPayment();
                          //add sa transaction collection
                          await db
                              .collection('users')
                              .doc(currentUser!.uid)
                              .collection('transaction')
                              .doc(ref)
                              .set({
                            'amount': -getTotal(),
                            'description': 'on hold',
                            'timestamp': DateTime.now(),
                          });
                        }
                        //if cash payment
                      } else if (widget.paymentMethod.toLowerCase() == "cash") {
                        addBookingWithPayment();
                      }
                    },
                    child: const Text(
                      'BOOK',
                      style: TextStyle(color: kPrimaryLightColor),
                    ))),
            const SizedBox(height: defaultPadding),
          ],
        )
      ],
    ));
  }

  Future<void> addBookingWithPayment() async {
    bookingToFirestore(
            format.format(double.parse(getServiceFeeFromList(prices))))
        .then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddedAppointment(
              reference: ref,
              amountPaid: getTotal().toStringAsFixed(2),
              paymentMethod: widget.paymentMethod,
              date:
                  '${DateFormat.jm().format(widget.dateTimeFrom)} - ${DateFormat.jm().format(widget.dateTimeTo)} | ${DateFormat('MMMMd').format(widget.dateTimeTo)}',
            ),
          ));
    });
  }

  Future<List<String>> getStaffs() async {
    List<String> staffList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .doc(widget.clientID)
          .collection('staff')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((element) {
          staffList.add(element['name']);
        });
      }
      staffList.add('Any');
      return staffList;
    } catch (e) {
      log('error getting staff $e');
      return [];
    }
  }

  double getTotal() {
    List<int> prices = [];

    widget.cart.values.forEach((element) {
      prices.add(int.parse(element.price));
    });

    if (prices.isEmpty) {
      return 0.0;
    }
    int sum = prices.reduce((value, element) => value + element);
    double total = double.parse(sum.toStringAsFixed(2));
    return total + (total * 0.05);
  }

  String getServiceFeeFromList(List<int> list) {
    if (list.isEmpty) {
      return '0.00';
    }
    int sum = list.reduce((value, element) => value + element);
    return (sum * .05).toStringAsFixed(2);
  }

  Future<void> bookingToFirestore(String serviceFee) async {
    List<Map<String, dynamic>> services = [];
    cart.forEach((element) {
      services.add({
        'serviceName': element.serviceName,
        'duration': element.duration,
        'price': double.parse(element.price),
      });
    });
    var newDocRef = db
        .collection('users')
        .doc(widget.clientID)
        .collection('bookings')
        .doc();
    setState(() {
      ref = newDocRef.id;
    });
    try {
      Map<String, dynamic> booking = {
        'serviceFee': widget.serviceFee,
        'totalAmount': format.format(getTotal()),
        'clientId': widget.clientID,
        'customerUsername': widget.customerUsername,
        'clientUsername': widget.clientUsername,
        'services': services,
        'dateFrom': widget.dateTimeFrom,
        'dateTo': widget.dateTimeTo,
        'status': 'pending',
        'paymentMethod': widget.paymentMethod,
        'location': widget.address,
        'reference': newDocRef.id,
      };
      //add appointment to client db
      await db
          .collection('users')
          .doc(widget.clientID)
          .collection('bookings')
          .doc(newDocRef.id)
          .set(booking);
      //add appointment to customer db
      await db
          .collection('users')
          .doc(currentUser!.uid)
          .collection('bookings')
          .doc(newDocRef.id)
          .set(booking);
      //add preferred stylist
      if (dropdownValue != null) {
        //client db
        await db
            .collection('users')
            .doc(widget.clientID)
            .collection('bookings')
            .doc(newDocRef.id)
            .update({
          'worker': dropdownValue,
        });
        //customer db
        await db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('bookings')
            .doc(newDocRef.id)
            .update({
          'worker': dropdownValue,
        });
      } else {
        //client db
        await db
            .collection('users')
            .doc(widget.clientID)
            .collection('bookings')
            .doc(newDocRef.id)
            .update({
          'worker': "Any",
        });
        //customer db
        await db
            .collection('users')
            .doc(currentUser!.uid)
            .collection('bookings')
            .doc(newDocRef.id)
            .update({
          'worker': "Any",
        });
      }
    } catch (e) {
      log('error uploading appointment $e');
    }
  }
}
