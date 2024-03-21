import 'dart:ui';

import 'package:customer/components/constants.dart';

class Event {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isAllDay;

  const Event({
    required this.title,
    required this.description,
    required this.from,
    required this.to,
    this.backgroundColor = kPrimaryColor,
    this.foregroundColor = kPrimaryLightColor,
    this.isAllDay = false,
  });
}
