import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/models/service.dart';
import 'package:customer/screens/customerProfile/custprofile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ApproveAppointment extends StatefulWidget {
  String clientID;
  String customerUsername;
  Map<String, ClientService> cart;
  String address;
  DateTime dateTimeFrom;
  DateTime dateTimeTo;
  String paymentMethod;

  ApproveAppointment({
    super.key,
    required this.clientID,
    required this.customerUsername,
    required this.cart,
    required this.address,
    required this.dateTimeFrom,
    required this.dateTimeTo,
    required this.paymentMethod,
  });

  @override
  State<ApproveAppointment> createState() => _ApproveAppointmentState();
}

class _ApproveAppointmentState extends State<ApproveAppointment> {
  late List<ClientService> cart;
  final format = NumberFormat('#,##0.00');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cart = widget.cart.values.toList();
    getTotal();
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
            BookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Customer Name'),
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
            BookingCard(Column(
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
                      List<int> prices = [];
                      cart.forEach((element) {
                        prices.add(int.parse(element.price));
                      });
                      return RowDetails([
                        const Text('Service Fee'),
                        Text(
                            'PHP ${format.format(double.parse(getServiceFee(prices)))}')
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
          ],
        ),
        Column(
          children: [
            Container(
                margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: ElevatedButton(
                    onPressed: () {
                      bookingToFirestore().then((value) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      });
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

  Row RowDetails(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Container BookingCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          vertical: defaultPadding, horizontal: defaultPadding * 2),
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: Offset(8, 8),
          )
        ],
      ),
      child: child,
    );
  }

  Container ServiceCard(String service) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
      decoration: const BoxDecoration(
          color: kPrimaryLightColor,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        service,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  String getServiceFee(List<int> list) {
    if (list.isEmpty) {
      return '0.00';
    }
    int sum = list.reduce((value, element) => value + element);
    return (sum * .05).toStringAsFixed(2);
  }

  Future<void> bookingToFirestore() async {
    List<Map<String, dynamic>> services = [];
    cart.forEach((element) {
      services.add({
        'serviceName': element.serviceName,
        'duration': element.duration,
        'price': double.parse(element.price),
      });
    });
    Map<String, dynamic> booking = {
      'customerUsername': widget.customerUsername,
      'clientID': widget.clientID,
      'services': services,
      'dateFrom': widget.dateTimeFrom,
      'dateTo': widget.dateTimeTo,
      'status': 'pending',
      'paymentMethod': widget.paymentMethod,
      'location': widget.address,
    };
    try {
      await db
          .collection('users')
          .doc(widget.clientID)
          .collection('bookings')
          .add(booking);
    } catch (e) {
      log('error uploading appointment $e');
    }
  }
}
