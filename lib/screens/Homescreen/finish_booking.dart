import 'dart:developer';

import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Homescreen/Homescreen.dart';
import 'package:customer/screens/Rating/rating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class FinishBooking extends StatefulWidget {
  Service transaction;
  FinishBooking({
    super.key,
    required this.transaction,
  });

  @override
  State<FinishBooking> createState() => _FinishBookingState();
}

class _FinishBookingState extends State<FinishBooking> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Background(
        child: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.fromLTRB(15, 50, 15, 0),
        child: Column(
          children: [
            const Text(
              'Appointment Finished!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: kPrimaryColor),
            ),
            const SizedBox(height: defaultPadding * 3),
            SizedBox.square(
              dimension: 250,
              child: SvgPicture.asset(
                'assets/svg/awesome.svg',
              ),
            ),
            const SizedBox(height: defaultPadding * 3),
            Text(
              "ref ${widget.transaction.reference}",
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(),
            details('Service Provider', widget.transaction.clientUsername),
            details('Payment Method', widget.transaction.paymentMethod),
            details('Date & Time',
                "${DateFormat.jm().format(widget.transaction.dateFrom)} - ${DateFormat.jm().format(widget.transaction.dateTo)} | ${DateFormat.MMMEd().format(widget.transaction.dateTo)}"),
            const Divider(),
            RowDetails([
              const Text('View'),
              Switch(
                value: switchValue,
                onChanged: (value) => setState(() {
                  switchValue = value;
                }),
              )
            ]),
            if (switchValue)
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.transaction.services!.length,
                itemBuilder: (context, index) {
                  return RowDetails([
                    Text(widget.transaction.services![index]['serviceName']),
                    Text(
                        "PHP ${widget.transaction.services![index]['price'].toStringAsFixed(2)}"),
                  ]);
                },
              ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Rating(
                          reference: widget.transaction.reference,
                          clientId: widget.transaction.clientId,
                        ),
                      ));
                },
                child: Text('Add rating',
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ],
        ),
      ),
    ));
  }
}

Container details(String title, String deets) {
  return Container(
    padding: const EdgeInsets.all(defaultPadding / 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.black45, fontWeight: FontWeight.w500),
        ),
        Text(
          deets,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
