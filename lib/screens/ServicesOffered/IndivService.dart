import 'package:customer/components/constants.dart';
import 'package:flutter/material.dart';

class IndivServicePage extends StatefulWidget {
  final String subserviceID;
  const IndivServicePage({super.key, required this.subserviceID});

  @override
  State<IndivServicePage> createState() => _IndivServicePageState();
}

class _IndivServicePageState extends State<IndivServicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
        title: Text(widget.subserviceID),
      ),
    );
  }
}
