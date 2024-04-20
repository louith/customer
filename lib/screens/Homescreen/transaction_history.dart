import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/components/widgets.dart';
import 'package:customer/screens/Homescreen/booking_transcations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TransactionHistory extends StatelessWidget {
  Transactions transactions;

  TransactionHistory({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
          child: Container(
        margin: const EdgeInsets.fromLTRB(15, 50, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('ref: ${transactions.reference}'),
            const SizedBox(height: defaultPadding),
            bookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Billing Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                RowDetails([
                  const Text('Payment Method'),
                  Text(transactions.paymentMethod),
                ]),
                RowDetails(
                    [const Text('Total'), Text('PHP ${transactions.total}')]),
                const Divider(),
                RowDetails([
                  const Text('Serivce Fee'),
                  Text('PHP ${transactions.serviceFee}'),
                ]),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: transactions.services.length,
                  itemBuilder: (context, index) {
                    return RowDetails([
                      Text('${transactions.services[index]['serviceName']}'),
                      Text(
                          'PHP ${transactions.services[index]['price'].toStringAsFixed(2)}'),
                    ]);
                  },
                ),
              ],
            )),
            const SizedBox(height: defaultPadding),
            bookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appointment Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                const Text('Time & Date'),
                Text(
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    '${DateFormat.jm().format(transactions.dateFrom)} - ${DateFormat.jm().format(transactions.dateTo)} | ${DateFormat('MMMMd').format(transactions.dateTo)}'),
                const SizedBox(height: defaultPadding),
                const Text('Address'),
                Text(transactions.location,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: defaultPadding),
                transactions.preferredWorker != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Preferred Stylist'),
                          Text(
                            transactions.preferredWorker!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    : Container()
              ],
            )),
            const SizedBox(height: defaultPadding),
            bookingCard(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: defaultPadding),
                RowDetails([
                  const Text('Booked Provider'),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      transactions.clientID,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ]),
                RowDetails([
                  const Text('Status'),
                  Text(
                    transactions.status.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ]),
                if (transactions.status == 'denied' &&
                    transactions.reason != null)
                  RowDetails([
                    const Text('Reason'),
                    Text(transactions.reason!),
                  ]),
              ],
            ))
          ],
        ),
      )),
    );
  }
}
