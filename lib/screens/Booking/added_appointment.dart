import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AddedAppointment extends StatelessWidget {
  String reference;
  String amountPaid;
  String paymentMethod;
  String date;

  AddedAppointment({
    super.key,
    required this.reference,
    required this.amountPaid,
    required this.paymentMethod,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
          child: Container(
        margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                const Text(
                  'Added Appointment',
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
                    'assets/svg/added.svg',
                  ),
                ),
                const SizedBox(height: defaultPadding * 3),
                const Text(
                  'Appointment Added!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: defaultPadding),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: defaultPadding),
                  child: const Text(
                    'Kindly wait for your service provider to respond to your request',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: defaultPadding),
                const Divider(color: Colors.black38),
                const SizedBox(height: defaultPadding),
                Text(
                  'ref: $reference',
                  style: const TextStyle(color: Colors.black45),
                ),
                const SizedBox(height: defaultPadding),
                InkWell(
                  child: const Text(
                    'Contact Service Provider',
                    style: TextStyle(
                      color: kPrimaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: kPrimaryColor,
                    ),
                  ),
                  onTap: () {
                    null;
                  },
                ),
                const SizedBox(height: defaultPadding),
                details('Amount Paid', 'PHP $amountPaid'),
                const Divider(color: Colors.black38),
                details('Payment Method', paymentMethod),
                const Divider(color: Colors.black38),
                details('Appointment Date', date),
                const Divider(color: Colors.black38),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: defaultPadding),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Home',
                    style: TextStyle(color: kPrimaryLightColor),
                  )),
            )
          ],
        ),
      )),
    );
  }

  // Container details(String title, String deets) {
  //   return Container(
  //     padding: const EdgeInsets.all(defaultPadding / 2),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //               color: Colors.black45, fontWeight: FontWeight.w500),
  //         ),
  //         Text(
  //           deets,
  //           style: TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
