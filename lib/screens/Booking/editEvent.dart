import 'package:customer/components/background.dart';
import 'package:customer/components/constants.dart';
import 'package:flutter/material.dart';

class BookingEventDetails extends StatefulWidget {
  const BookingEventDetails({super.key});

  @override
  State<BookingEventDetails> createState() => _BookingEventDetailsState();
}

class _BookingEventDetailsState extends State<BookingEventDetails> {
  void _showBackDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Returning to Calendar"),
          content: const Text(
            'Are you sure you want to go back?',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'BACK',
              ),
              onPressed: () {
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        _showBackDialog();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: IconButton(
            onPressed: _showBackDialog,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
          actions: <Widget>[
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.check,
                color: Colors.white,
              ),
              label: const Text(
                'Book',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        body: Background(child: Container()),
      ),
    );
  }
}
