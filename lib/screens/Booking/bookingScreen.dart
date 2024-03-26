import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/components/constants.dart';
import 'package:customer/features/parse.dart';
import 'package:customer/screens/Booking/EditEventComponents/event_provider.dart';
import 'package:customer/screens/Booking/editEvent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class BookingScreen extends StatefulWidget {
  String username;
  String userID;
  BookingScreen({super.key, required this.username, required this.userID});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<String> calendarViewOptions = [
    'Week',
    'Day',
    'Month',
  ];
  String selectedView = 'Week';
  Parse parser = Parse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        foregroundColor: kPrimaryLightColor,
        title: Text(widget.username),
      ),
      body: Column(
        children: [
          FutureBuilder(
            future: getAppointments(),
            builder: (context, appointments) {
              if (appointments.hasData) {
                return Expanded(
                  child: SfCalendar(
                    view: CalendarView.month,
                    dataSource: MeetingDataSource(appointments.data!),
                    allowedViews: const [
                      CalendarView.month,
                      CalendarView.week,
                      CalendarView.day,
                      CalendarView.schedule,
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BookingAppointment(userID: widget.userID)));
          },
          backgroundColor: kPrimaryColor,
          child: const Icon(
            Icons.add,
            color: kPrimaryLightColor,
          )),
    );
  }

  Future<List<Appointment>> getAppointments() async {
    List<Map<String, dynamic>> appointments = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userID)
          .collection('bookings')
          .get();
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        appointments.add(data);
      });

      final List<Appointment> appointmentList = appointments.map((a) {
        // Assign a default color if 'status' doesn't match any expected values
        final color = a['status'] == 'pending'
            ? const Color.fromARGB(255, 158, 158, 158)
            : a['status'] == 'confirmed'
                ? kPrimaryColor
                : const Color.fromARGB(255, 76, 175, 80);
        final appointment = Appointment(
          id: a['reference'].toString(),
          subject: parser.extractServiceNamesFromListofMap(
              parser.stringToMap(a['services'].toString())),
          notes: a['customerID'].toString(),
          location: a['location'],
          startTime: a['dateFrom'].toDate(),
          endTime: a['dateTo'].toDate(),
          color: color, // Fallback color
        );
        return appointment;
      }).toList();

      return appointmentList;
    } catch (e) {
      log('Error getting appointments: $e');
      return []; // Return empty list in case of error
    }
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}
